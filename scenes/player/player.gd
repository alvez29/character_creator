class_name Player
extends CharacterBody3D

@export_category("Settings")
@export var mouse_sensitivity: float = 0.003

@export_category("Components")
@export var pawn_component: PawnComponent
@export var input_handler: InputHandlerComponent
@export var movement_component: FirstPersonMovementComponent
@export var grabbing_behavior_component: GrabbingBehaviorComponent
@export var camera_manager: FirstPersonCameraManager

@onready var _head: Node3D = %Head
@onready var _collision_shape: CollisionShape3D = %PlayerCollision

var _crouch_tween: Tween
var _crouch_tween_speed: float = 0.15


func _ready() -> void:
	floor_snap_length = 0.5
	floor_stop_on_slope = false

	if pawn_component:
		pawn_component.on_possessed.connect(_on_possessed)
		pawn_component.on_unpossessed.connect(_on_unpossessed)
		if pawn_component.is_possessed:
			_on_possessed()

	if input_handler:
		input_handler.crouch_pressed.connect(_on_crouch_pressed)
		input_handler.crouch_released.connect(_on_crouch_released)
		input_handler.camera_rotation.connect(_on_camera_rotation)

	if movement_component:
		movement_component.on_crouch_height_changed.connect(_on_crouch_height_changed)
		movement_component.on_eyes_height_changed.connect(_tween_eyes_height)

#region Possession
func _on_possessed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if camera_manager: camera_manager.active_camera()
	if input_handler: input_handler.is_active = true


func _on_unpossessed() -> void:
	if input_handler: input_handler.is_active = false
#endregion


#region Movement
func _process(_delta: float) -> void:
	if not input_handler or not movement_component: return
	movement_component.set_sprinting(input_handler.is_sprinting)
	if camera_manager: 
		camera_manager.tilt(input_handler.movement_dir.x)


func _physics_process(delta: float) -> void:
	if not input_handler or not movement_component: return
	
	input_handler.process_inputs()
	
	var input_dir := input_handler.movement_dir
	var wish_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	movement_component.move(wish_dir, delta)
	
	if input_handler.is_jumping and is_on_floor():
		movement_component.jump()


func _on_crouch_pressed() -> void:
	if not movement_component: return
	movement_component.crouch()


func _on_crouch_released() -> void:
	if not movement_component: return
	movement_component.uncrouch()


func _on_camera_rotation(mouse_delta: Vector2) -> void:
	rotate_y(-mouse_delta.x * mouse_sensitivity)
	_head.rotate_x(-mouse_delta.y * mouse_sensitivity)
	_head.rotation.x = clamp(_head.rotation.x, deg_to_rad(-80), deg_to_rad(80))
#endregion


#region Crouching (reacts to MovementComponent signals)
func _on_crouch_height_changed(delta: float) -> void:
	_collision_shape.shape.height = max(_collision_shape.shape.height + delta, 0.8)


func _tween_eyes_height(target_height: float) -> void:
	if _crouch_tween: _crouch_tween.kill()
	_crouch_tween = create_tween()
	_crouch_tween.set_ease(Tween.EASE_OUT)
	_crouch_tween.set_trans(Tween.TRANS_CUBIC)
	_crouch_tween.tween_property(_head, "position:y", target_height, _crouch_tween_speed)
#endregion


#region External Physics (pasarelas al MovementComponent)
func add_impulse(impulse: Vector3) -> void:
	if movement_component: movement_component.add_impulse(impulse)

func add_force(force: Vector3) -> void:
	if movement_component: movement_component.add_force(force)
#endregion
