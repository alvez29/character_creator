class_name Player
extends CharacterBody3D

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
@export var acceleration: float = 12.0
@export var friction: float = 10.0
@export var air_control: float = 3.0
@export var jump_velocity: float = 5.0

@onready var _head: Node3D = %Head
@warning_ignore("unused_private_class_variable")
@onready var _camera: Camera3D = %PlayerCamera
@onready var _collision_shape: CollisionShape3D = %PlayerCollision

var _is_crouched := false
var _crouch_tween: Tween

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_camera.current = true
	
	_head.position = Vector3(_head.position.x, eyes_height, _head.position.z)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event.is_action_pressed("crouch"):
		_process_crouching()
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
	else:
		return max_speed


func _process_movement(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var speed := _get_desired_max_speed()
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var wish_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var accel := acceleration if is_on_floor() else air_control

	if wish_dir != Vector3.ZERO:
		velocity.x = move_toward(velocity.x, wish_dir.x * speed, accel * delta)
		velocity.z = move_toward(velocity.z, wish_dir.z * speed, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)
		velocity.z = move_toward(velocity.z, 0.0, friction * delta)

	move_and_slide()
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
func _process_crouching() -> void:
	if _is_crouched:
		uncrouch()
	else:
		crouch()


func crouch() -> void:
	_collision_shape.shape.height = max(_collision_shape.shape.height - crouch_distance, 0.8)
	_tween_eyes_height(eyes_height - crouch_distance)
	_is_crouched = true


func uncrouch() -> void:
	_collision_shape.shape.height += crouch_distance
	_tween_eyes_height(eyes_height)
	_is_crouched = false
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
