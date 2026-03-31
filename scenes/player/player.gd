class_name Player
extends CharacterBody3D

signal on_grababble_on_distance

@export_category("Settings")
@export var eyes_height: float = 2.0
@export var mouse_sensitivity: float = 0.003

@export_category("Crouching")
@export var crouch_distance: float = 0.5
@export var crouch_tween_speed: float = 0.15

@export_category("Camera")
@export var tilt_angle: float = 1.5
@export var tilt_speed: float = 8.0 
@export var camera_tilting: bool = true

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
@export var slide_friction: float = 5.0
@export var slide_max_speed: float = 100.0
@export var slide_boost: float = 2.0
@export var can_steer_while_sliding: bool = true
@export var slide_steering: float = 10.0

@export_category("Physics")
@export var mass: float = 1.0

@export_category("References")
@export var grabbing_behavior_component: GrabbingBehaviorComponent

@onready var _head: Node3D = %Head
@warning_ignore("unused_private_class_variable")
@onready var _camera: Camera3D = %PlayerCamera
@onready var _collision_shape: CollisionShape3D = %PlayerCollision


var _is_crouched := false
var _is_sliding := false
var _crouch_tween: Tween
var _accumulated_force: Vector3 = Vector3.ZERO

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_camera.current = true
	
	_head.position = Vector3(_head.position.x, eyes_height, _head.position.z)
	
	# Evitar que el personaje salga despedido de las rampas por la inercia (micro-saltos)
	floor_snap_length = 0.5
	# Desactivar el autobloqueo estático de Godot en pendientes para permitir deslizamientos puros
	floor_stop_on_slope = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event.is_action_pressed("crouch"):
		crouch(false)
	elif event.is_action_released("crouch"):
		uncrouch()
	if event is InputEventMouseButton and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_process_camera_rotation(event.relative)


func _process(delta: float) -> void:
	_process_camera_tilting(delta)

func _physics_process(delta: float) -> void:
	_process_movement(delta)

#region Movement
func _get_desired_max_speed() -> float:
	if Input.is_action_pressed("sprint") and not _is_crouched:
		return sprint_max_speed
	elif _is_crouched:
		return crouch_max_speed
	elif _is_sliding:
		return slide_max_speed
	else:
		return max_speed


func _process_movement(delta: float) -> void:
	if not is_on_floor():
		add_force(get_gravity() * mass)
		if _is_crouched:
			uncrouch()
	elif _is_sliding:
		var slope_force := get_gravity().slide(get_floor_normal())
		add_force(slope_force * mass)

	velocity += (_accumulated_force / mass) * delta
	_accumulated_force = Vector3.ZERO

	if is_on_floor():
		if Input.is_action_pressed("jump"):
			velocity.y = jump_velocity
			_is_sliding = false
			if _is_crouched: uncrouch()
		else:
			var h_vel := Vector3(velocity.x, 0, velocity.z)
			if _is_sliding:
				h_vel = h_vel.move_toward(Vector3.ZERO, slide_friction * delta)
				velocity.x = h_vel.x
				velocity.z = h_vel.z
				
				# Cancel slide if too slow
				if h_vel.length() < max_speed:
					_is_sliding = false
			else:
				h_vel = h_vel.move_toward(Vector3.ZERO, ground_friction * delta)
				velocity.x = h_vel.x
				velocity.z = h_vel.z

	var speed := _get_desired_max_speed()
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
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

	var was_on_floor := is_on_floor()
	move_and_slide()

	if is_on_floor() and not was_on_floor:
		if Input.is_action_pressed("crouch") and not _is_crouched:
			crouch(true)
#endregion

#region Camera
func _process_camera_rotation(mouse_delta: Vector2) -> void:
	rotate_y(-mouse_delta.x * mouse_sensitivity)
	_head.rotate_x(-mouse_delta.y * mouse_sensitivity)
	_head.rotation.x = clamp(_head.rotation.x, deg_to_rad(-80), deg_to_rad(80))


func _process_camera_tilting(delta):
	if camera_tilting:
		var input_x := Input.get_axis("move_left", "move_right")
		var target_tilt := deg_to_rad(-tilt_angle) * input_x
		_camera.rotation.z = lerp(_camera.rotation.z, target_tilt, tilt_speed * delta)
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
		if h_vel.length() >= slide_min_speed:
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

#region Interactibility
func _check_close_interactable():
	var origin := get_viewport().get_camera_3d().global_position
	var target = origin + (-get_viewport().get_camera_3d().global_transform.basis.z * grabbing_behavior_component.interact_distance)
	var hit = Utils._cast_ray(get_world_3d(), origin, target)
	
	if hit and hit.collider is Grabbable and hit.collider is RigidBody3D:
		on_grababble_on_distance.emit()
#endregion
