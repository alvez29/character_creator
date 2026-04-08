class_name FirstPersonMovementComponent
extends Node

## Emitted when crouching so the owner can adjust collision shape.
signal on_crouch_height_changed(delta: float)
## Emitted when eyes height should tween to a new position.
signal on_eyes_height_changed(target_height: float)
signal on_started_sliding
signal on_finished_sliding

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
@export var slide_min_slope_angle: float = deg_to_rad(10)
@export var slide_max_speed: float = 100.0
@export var slide_boost: float = 2.0
@export var slide_gravity_multiplier: float = 2.5
@export var can_steer_while_sliding: bool = true
@export var slide_steering: float = 10.0

@export_category("Crouching")
@export var crouch_distance: float = 0.5
@export var eyes_height: float = 2.0

@export_category("Physics")
@export var mass: float = 1.0

var _body: CharacterBody3D

var _is_crouched := false
var _is_sliding := false : set = _set_is_sliding
var _is_sprinting := false
var _crouch_queued := false
var _accumulated_force: Vector3 = Vector3.ZERO
var _just_landed_flag := false
var _last_sliding_state := false


func _ready() -> void:
	_body = get_parent() as CharacterBody3D
	if not _body:
		push_error("FirstPersonMovementComponent: parent must be a CharacterBody3D")


func _physics_process(delta: float) -> void:
	if not _body: return
	
	_apply_gravity_and_slope_forces()
	_apply_accumulated_forces(delta)
	_apply_friction(delta)
	
	var was_on_floor := _body.is_on_floor()
	_body.move_and_slide()
	_just_landed_flag = _body.is_on_floor() and not was_on_floor
	
	if _just_landed_flag and _crouch_queued:
		_crouch_queued = false
		crouch(true)
	
	if _last_sliding_state != _is_sliding:
		if _is_sliding:
			on_started_sliding.emit()
		else:
			on_finished_sliding.emit()


func _set_is_sliding(value):
	if _last_sliding_state != value:
		if value:
			on_started_sliding.emit()
		else:
			on_finished_sliding.emit()
	
	_last_sliding_state = _is_sliding
	_is_sliding = value

#region Public API
func move(wish_dir: Vector3, delta: float) -> void:
	var speed := _get_desired_max_speed()
	var accel := air_acceleration
	var speed_limit := air_speed_limit
	
	if _body.is_on_floor():
		if _is_sliding:
			accel = slide_steering if can_steer_while_sliding else 0.0
			speed_limit = 0.0
		else:
			accel = ground_acceleration
			speed_limit = speed

	var current_proj_speed := wish_dir.dot(_body.velocity)
	var add_speed := clampf(speed_limit - current_proj_speed, 0.0, accel * delta)
	_body.velocity += wish_dir * add_speed


func jump() -> void:
	if not _body.is_on_floor(): return
	_body.velocity.y = jump_velocity
	_is_sliding = false
	_crouch_queued = false
	if _is_crouched:
		uncrouch()


func queue_jump() -> void:
	## Call when not on floor - will jump as soon as landing occurs
	pass


func crouch(from_queue := false) -> void:
	if not _body.is_on_floor():
		_crouch_queued = true
		return
	if _is_crouched: return
	
	emit_signal("on_crouch_height_changed", -crouch_distance)
	emit_signal("on_eyes_height_changed", eyes_height - crouch_distance)
	_is_crouched = true
	
	var h_vel := Vector3(_body.velocity.x, 0, _body.velocity.z)
	
	if h_vel.length() >= slide_min_speed and (_is_sprinting or from_queue):
		_is_sliding = true
		if not from_queue and h_vel.length() > 0:
			add_impulse(h_vel.normalized() * slide_boost * mass)


func uncrouch() -> void:
	if not _is_crouched: return
	emit_signal("on_crouch_height_changed", crouch_distance)
	emit_signal("on_eyes_height_changed", eyes_height)
	_is_crouched = false
	_is_sliding = false
	_crouch_queued = false


func set_sprinting(value: bool) -> void:
	_is_sprinting = value


func add_impulse(impulse: Vector3) -> void:
	if _body: _body.velocity += impulse / mass


func add_force(force: Vector3) -> void:
	_accumulated_force += force
#endregion


#region Internal
func _get_desired_max_speed() -> float:
	if _is_sprinting and not _is_crouched: return sprint_max_speed
	if _is_crouched: return crouch_max_speed
	if _is_sliding: return slide_max_speed
	return max_speed


func _apply_gravity_and_slope_forces() -> void:
	if not _body.is_on_floor():
		add_force(_body.get_gravity() * mass)
		if _is_crouched:
			uncrouch()
	elif _is_sliding:
		var slope_force := _body.get_gravity().slide(_body.get_floor_normal()) * slide_gravity_multiplier
		add_force(slope_force * mass)


func _apply_accumulated_forces(delta: float) -> void:
	_body.velocity += (_accumulated_force / mass) * delta
	_accumulated_force = Vector3.ZERO


func _apply_friction(delta: float) -> void:
	if not _body.is_on_floor(): return
	var h_vel := Vector3(_body.velocity.x, 0, _body.velocity.z)
	var friction := slide_friction * delta if _is_sliding else ground_friction * delta
	h_vel = h_vel.move_toward(Vector3.ZERO, friction)
	
	if _is_sliding and h_vel.length() < max_speed and _body.get_floor_angle() < slide_min_slope_angle:
		_is_sliding = false
	
	_body.velocity.x = h_vel.x
	_body.velocity.z = h_vel.z
#endregion
