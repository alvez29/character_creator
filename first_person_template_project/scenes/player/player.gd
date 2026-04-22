## Main component representing the player character, managing movement, input processing and component coordination.
class_name Player
extends CharacterBody3D

enum CrouchMode { HOLD, TOGGLE }

@export_category("Controls")
@export var crouch_mode: CrouchMode = CrouchMode.HOLD

@export_category("Components")
@export var pawn_component: PawnComponent
@export var input_handler: InputHandlerComponent
@export var movement_component: FirstPersonMovementComponent
@export var grabbing_behavior_component: GrabbingBehaviorComponent
@export var camera_shake_component: ShakerComponent
@export var camera_manager: FirstPersonCameraManager
@export var camera_pivot: Node3D
@export var collision_shape: CollisionShape3D
@export var camera: Camera3D
@export var punching_behavior_component: PunchingBehaviorComponent
@export var speed_lines: CPUParticles3D

var speed: float:
	get:
		return velocity.length()

var _crouch_tween: Tween
var _crouch_tween_speed: float = 0.15
var _is_crouch_action_pressed: bool = false

func _ready() -> void:
	floor_snap_length = 0.5
	floor_stop_on_slope = false

	if pawn_component:
		pawn_component.on_possessed.connect(_on_pawn_component_on_possessed)
		pawn_component.on_unpossessed.connect(_on_pawn_component_on_unpossessed)
		if pawn_component.is_possessed:
			_on_pawn_component_on_possessed()

	if input_handler:
		input_handler.crouch_started_pressed.connect(_on_input_handler_component_on_crouch_started_pressed)
		input_handler.crouch_released.connect(_on_input_handler_component_on_crouch_released)
		input_handler.sprint_started_pressed.connect(_on_input_handler_component_on_sprint_started_pressed)

	if movement_component:
		movement_component.on_crouch_height_changed.connect(_on_movement_component_on_crouch_height_changed)
		movement_component.on_eyes_height_changed.connect(_on_movement_component_on_eyes_height_changed)
		movement_component.on_finished_sliding.connect(_on_movement_component_on_finished_sliding)
	
	if punching_behavior_component:
		punching_behavior_component.on_punch_collider_collided.connect(_on_punching_behavior_component_on_punch_collider_collided)



#region Possession
func _on_pawn_component_on_possessed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if camera_manager: camera_manager.active_camera()
	if input_handler: input_handler.is_active = true


func _on_pawn_component_on_unpossessed() -> void:
	if input_handler: input_handler.is_active = false
#endregion


#region Movement
func _process(delta: float) -> void:
	if not input_handler: return
	
	var mouse_delta = input_handler.consume_mouse_delta()
	
	if mouse_delta != Vector2.ZERO:
		rotate_y(-mouse_delta.x * SettingsManager.mouse_sensitivity)
		camera_pivot.rotate_x(-mouse_delta.y * SettingsManager.mouse_sensitivity)
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	
	if camera_manager and movement_component:
		movement_component.set_sprinting(input_handler.is_sprinting)
		
		var is_running = movement_component.is_sprinting
		var is_sliding = movement_component.is_sliding
		var is_wall_running = movement_component.is_wall_running
		var in_air = not is_on_floor()
		
		var tilt_val = input_handler.movement_dir.x
		if is_wall_running:
			var dot = transform.basis.x.dot(movement_component._wall_normal)
			tilt_val = clamp(dot * 15.0, -15.0, 15.0)
			
		camera_manager.tilt(tilt_val, delta)
		camera_manager.adjust_dynamic_fov(delta, speed, is_running or is_sliding or is_wall_running or in_air)
		
		update_speedlines()


func update_speedlines():
	speed_lines.emitting = speed > movement_component.max_speed
	
	if speed_lines and speed > movement_component.max_speed:
		var speed_diference = movement_component.sprint_max_speed - speed
		
		speed_lines.amount = clamp(remap(speed_diference, 5.0, 10.0, 30.0, 40.0), 30.0, 40)

func _physics_process(delta: float) -> void:
	if not input_handler or not movement_component: return
	
	input_handler.process_movement_related_inputs()
	
	var input_dir := input_handler.movement_dir
	var wish_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	movement_component.move(wish_dir, delta)
	
	if input_handler.is_jumping and is_on_floor():
		movement_component.jump()
	elif input_handler.is_jump_just_pressed and movement_component.is_wall_running:
		movement_component.jump()


func _on_input_handler_component_on_crouch_started_pressed() -> void:
	if not movement_component: return
	_is_crouch_action_pressed = true
	
	if movement_component.is_sliding:
		movement_component.uncrouch()
	elif crouch_mode == CrouchMode.TOGGLE:
		if movement_component.is_crouched:
			movement_component.uncrouch()
		else:
			movement_component.crouch()
	else:
		movement_component.crouch()


func _on_punching_behavior_component_on_punch_collider_collided(_punching_data: PunchingBehaviorComponent.PunchingCollisionData):
	if movement_component.is_wall_running:
		movement_component.cancel_wall_run()


func _on_input_handler_component_on_crouch_released() -> void:
	if not movement_component: return
	_is_crouch_action_pressed = false
	
	if crouch_mode == CrouchMode.HOLD:
		if not movement_component.is_sliding:
			movement_component.uncrouch()


func _on_input_handler_component_on_sprint_started_pressed() -> void:
	if not movement_component: return
	if movement_component.is_sliding or movement_component.is_crouched:
		movement_component.uncrouch()


func _on_movement_component_on_finished_sliding() -> void:
	if crouch_mode == CrouchMode.HOLD and not _is_crouch_action_pressed:
		if movement_component and movement_component.is_crouched:
			movement_component.uncrouch()
#endregion


#region Crouching
func _on_movement_component_on_crouch_height_changed(delta: float) -> void:
	collision_shape.shape.height = max(collision_shape.shape.height + delta, 0.8)


func _on_movement_component_on_eyes_height_changed(target_height: float) -> void:
	if _crouch_tween: _crouch_tween.kill()
	_crouch_tween = create_tween()
	_crouch_tween.set_ease(Tween.EASE_OUT)
	_crouch_tween.set_trans(Tween.TRANS_CUBIC)
	_crouch_tween.tween_property(camera_pivot, "position:y", target_height, _crouch_tween_speed)
#endregion


#region External Physics
func add_impulse(impulse: Vector3) -> void:
	if movement_component: movement_component.add_impulse(impulse)

func add_force(force: Vector3) -> void:
	if movement_component: movement_component.add_force(force)
#endregion
