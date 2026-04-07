class_name Player
extends CharacterBody3D

@export_category("Settings")
@export var eyes_height: float = 2.0
@export var mouse_sensitivity: float = 0.003

@export_category("Crouching")
@export var is_crouch_toggle: bool = false
@export var crouch_distance: float = 0.5
@export var crouch_tween_speed: float = 0.15

@export_category("Camera")
@export var camera_manager: FirstPersonCameraManager

@export_category("Movement")
@export var max_speed: float = 6.0
@export var crouch_max_speed: float = 2.0
@export var sprint_max_speed: float = 10.0
@export var ground_acceleration: float = 60.0
@export var ground_friction: float = 40.0
@export var air_acceleration: float = 50.0
@export var air_speed_limit: float = 1.0
@export var jump_velocity: float = 5.0

@export_category("Sliding")
@export var slide_min_speed: float = 5.0
@export var slide_friction: float = 1.0
@export var slide_max_speed: float = 100.0
@export var slide_boost: float = 2.0
@export var slide_gravity_multiplier: float = 2.5
@export var can_steer_while_sliding: bool = true
@export var slide_steering: float = 10.0

@export_category("Physics")
@export var mass: float = 1.0

@export_category("References")
@export var grabbing_behavior_component: GrabbingBehaviorComponent

@onready var _head: Node3D = %Head
@onready var _collision_shape: CollisionShape3D = %PlayerCollision


var _is_crouched := false
var _is_sliding := false
var _crouch_on_queue := false
var _crouch_tween: Tween
var _accumulated_force: Vector3 = Vector3.ZERO
var _just_landed_flag := false


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera_manager.active_camera()
	
	_head.position = Vector3(_head.position.x, eyes_height, _head.position.z)
	
	floor_snap_length = 0.5
	floor_stop_on_slope = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event.is_action_pressed("movement_crouch"):
		if is_on_floor():
			if is_crouch_toggle:
				if _is_crouched:
					uncrouch()
				else:
					crouch(false)
			else:
				crouch(false)
		else:
			if is_crouch_toggle:
				_crouch_on_queue = not _crouch_on_queue
			else:
				_crouch_on_queue = true
	elif event.is_action_released("movement_crouch"):
		if not is_crouch_toggle:
			if _is_crouched:
				uncrouch()
			_crouch_on_queue = false
	if event is InputEventMouseButton and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_process_camera_rotation(event.relative)


func _process(_delta: float) -> void:
	_process_feedback()

func _physics_process(delta: float) -> void:
	_process_movement(delta)

func _process_feedback():
	_process_camera_tilting()
	

#region Movement
func _get_desired_max_speed() -> float:
	if Input.is_action_pressed("movement_sprint") and not _is_crouched:
		return sprint_max_speed
	elif _is_crouched:
		return crouch_max_speed
	elif _is_sliding:
		return slide_max_speed
	else:
		return max_speed


func _process_movement(delta: float) -> void:
	_handle_landing()
	_apply_gravity_and_slope_forces()
	_apply_accumulated_forces(delta)

	if is_on_floor():
		if Input.is_action_pressed("movement_jump"):
			_handle_jump()
		else:
			_apply_friction(delta)

	_apply_movement_acceleration(delta)

	var was_on_floor_before_move := is_on_floor()
	move_and_slide()
	_just_landed_flag = is_on_floor() and not was_on_floor_before_move


func _handle_landing() -> void:
	if _just_landed_flag:
		var wants_crouch := _crouch_on_queue if is_crouch_toggle else Input.is_action_pressed("movement_crouch")
		_crouch_on_queue = false
		if wants_crouch and not _is_crouched:
			crouch(true)


func _apply_gravity_and_slope_forces() -> void:
	if not is_on_floor():
		add_force(get_gravity() * mass)
		if _is_crouched: 
			uncrouch()
	elif _is_sliding:
		var slope_force := get_gravity().slide(get_floor_normal()) * slide_gravity_multiplier
		add_force(slope_force * mass)


func _apply_accumulated_forces(delta: float) -> void:
	velocity += (_accumulated_force / mass) * delta
	_accumulated_force = Vector3.ZERO


func _handle_jump() -> void:
	velocity.y = jump_velocity
	_is_sliding = false
	_crouch_on_queue = false
	if _is_crouched: 
		uncrouch()


func _apply_friction(delta: float) -> void:
	var h_vel := Vector3(velocity.x, 0, velocity.z)
	var friction := slide_friction * delta if _is_sliding else ground_friction * delta
	
	h_vel = h_vel.move_toward(Vector3.ZERO, friction)
	
	if _is_sliding:
		var movement_too_slow_to_slide := h_vel.length() < max_speed
		if movement_too_slow_to_slide: 
			_is_sliding = false
	
	velocity.x = h_vel.x
	velocity.z = h_vel.z


func _apply_movement_acceleration(delta: float) -> void:
	var speed := _get_desired_max_speed()
	var input_dir := Input.get_vector("movement_move_left", "movement_move_right", "movement_move_forward", "movement_move_backward")
	var wish_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	var accel := air_acceleration
	var speed_limit := air_speed_limit
	
	if is_on_floor():
		if _is_sliding:
			accel = slide_steering if can_steer_while_sliding else 0.0
			speed_limit = 0.0
		else:
			accel = ground_acceleration
			speed_limit = speed

	var current_proj_speed := wish_dir.dot(velocity)
	var add_speed := clampf(speed_limit - current_proj_speed, 0.0, accel * delta)
	
	velocity += wish_dir * add_speed
#endregion

#region Camera
func _process_camera_rotation(mouse_delta: Vector2) -> void:
	rotate_y(-mouse_delta.x * mouse_sensitivity)
	_head.rotate_x(-mouse_delta.y * mouse_sensitivity)
	_head.rotation.x = clamp(_head.rotation.x, deg_to_rad(-80), deg_to_rad(80))


func _process_camera_tilting():
	var input_x := Input.get_axis("movement_move_left", "movement_move_right")
	if camera_manager: camera_manager.tilt(input_x)


func active_camera():
	camera_manager.active_camera()
#endregion

#region Crouching
func crouch(from_queue := false) -> void:
	if not is_on_floor():
		return
		
	_collision_shape.shape.height = max(_collision_shape.shape.height - crouch_distance, 0.8)
	_tween_eyes_height(eyes_height - crouch_distance)
	_is_crouched = true
	
	if is_on_floor():
		var h_vel := Vector3(velocity.x, 0, velocity.z)
		if h_vel.length() >= slide_min_speed and (Input.is_action_pressed("movement_sprint") or from_queue):
			_is_sliding = true
			if not from_queue and h_vel.length() > 0:
				add_impulse(h_vel.normalized() * slide_boost * mass)


func uncrouch() -> void:
	_collision_shape.shape.height += crouch_distance
	_tween_eyes_height(eyes_height)
	_is_crouched = false
	_is_sliding = false
#endregion

#region Eyes
func _tween_eyes_height(target_height: float) -> void:
	if _crouch_tween:
		_crouch_tween.kill()
	_crouch_tween = create_tween()
	_crouch_tween.set_ease(Tween.EASE_OUT)
	_crouch_tween.set_trans(Tween.TRANS_CUBIC)
	_crouch_tween.tween_property(_head, "position:y", target_height, crouch_tween_speed)
#endregion

#region External Physics
func add_impulse(impulse: Vector3) -> void:
	velocity += impulse / mass

func add_force(force: Vector3) -> void:
	_accumulated_force += force
#endregion
