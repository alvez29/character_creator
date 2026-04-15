## Component that handles first-person physics movement mechanics including walking, sprinting, jumping, crouching, sliding, and wall-running.
class_name FirstPersonMovementComponent
extends Node

signal on_crouch_height_changed(delta: float)
signal on_eyes_height_changed(target_height: float)
signal on_started_sliding
signal on_finished_sliding


@export_category("Body")
@export var body: CharacterBody3D

@export_category("Movement")
@export var max_speed: float = 6.0
@export var crouch_max_speed: float = 2.0
@export var sprint_max_speed: float = 10.0
@export var ground_acceleration: float = 60.0
@export var ground_friction: float = 40.0
@export var air_acceleration: float = 50.0
@export var air_speed_limit: float = 1.0
@export var jump_velocity: float = 7
@export var gravity_factor: float = 1
@export var gravity_vector: Vector3 = Vector3(0, -9.8, 0)

@export_category("Wall Running")
@export var can_wall_run: bool = true
@export var wall_run_max_duration: float = 1.5
@export var wall_run_gravity_multiplier: float = 0.2
@export var wall_run_min_speed: float = 3.0
@export var wall_jump_force: float = 6.0
@export var wall_jump_push_force: float = 6.0
@export var wall_run_fall_speed: float = 1.2
@export var wall_run_angle_limit: float = -0.75

@export_category("Sliding")
@export var slide_min_speed: float = 6.0
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

var _is_crouched := false
var _is_sliding := false : set = _set_is_sliding
var _is_sprinting := false
var _is_wall_running := false
var _wall_normal := Vector3.ZERO
var _wall_run_timer := 0.0
var _crouch_queued := false
var _accumulated_force: Vector3 = Vector3.ZERO
var _just_landed_flag := false
var _last_sliding_state := false


func _ready() -> void:
	if not body:
		body = get_parent() as CharacterBody3D
	
	if not body:
		push_error("FirstPersonMovementComponent: parent must be a CharacterBody3D")


func _physics_process(delta: float) -> void:
	if not body: return
	
	_handle_wall_run_state(delta)
	
	_apply_gravity_and_slope_forces()
	_apply_accumulated_forces(delta)
	_apply_friction(delta)
	
	var was_on_floor := body.is_on_floor()
	body.move_and_slide()
	_just_landed_flag = body.is_on_floor() and not was_on_floor
	
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
	
	if body.is_on_floor():
		if _is_sliding:
			accel = slide_steering if can_steer_while_sliding else 0.0
			speed_limit = 0.0
		else:
			accel = ground_acceleration
			speed_limit = speed

	var current_proj_speed := wish_dir.dot(body.velocity)
	var add_speed := clampf(speed_limit - current_proj_speed, 0.0, accel * delta)
	body.velocity += wish_dir * add_speed


func jump() -> void:
	if _is_wall_running:
		body.velocity.y = wall_jump_force
		body.velocity += _wall_normal * wall_jump_push_force
		_is_wall_running = false
		_wall_run_timer = wall_run_max_duration
		return

	if not body.is_on_floor(): return
	body.velocity.y = jump_velocity
	_is_sliding = false
	_crouch_queued = false
	if _is_crouched:
		uncrouch()


func queue_jump() -> void:
	## Call when not on floor - will jump as soon as landing occurs
	pass


func crouch(from_queue := false) -> void:
	if not body.is_on_floor():
		_crouch_queued = true
		return
	if _is_crouched: return
	
	emit_signal("on_crouch_height_changed", -crouch_distance)
	emit_signal("on_eyes_height_changed", eyes_height - crouch_distance)
	_is_crouched = true
	
	var h_vel := Vector3(body.velocity.x, 0, body.velocity.z)
	
	if h_vel.length() >= slide_min_speed:
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
	if body:
		body.velocity += impulse / mass


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
	if not body.is_on_floor():
		if _is_wall_running:
			add_force(-_wall_normal * 40.0 * mass)
			body.velocity = body.velocity.slide(_wall_normal)
			body.velocity.y = min(body.velocity.y, 0.0)
			body.velocity.y = max(body.velocity.y, -wall_run_fall_speed)
		else:
			add_force(gravity_vector * gravity_factor  * mass)
		if _is_crouched:
			uncrouch()
	elif _is_sliding:
		var slope_force := (gravity_vector * gravity_factor).slide(body.get_floor_normal()) * slide_gravity_multiplier
		add_force(slope_force * mass)


func _apply_accumulated_forces(delta: float) -> void:
	body.velocity += (_accumulated_force / mass) * delta
	_accumulated_force = Vector3.ZERO


func _apply_friction(delta: float) -> void:
	if not body.is_on_floor(): return
	var h_vel := Vector3(body.velocity.x, 0, body.velocity.z)
	var friction := slide_friction * delta if _is_sliding else ground_friction * delta
	h_vel = h_vel.move_toward(Vector3.ZERO, friction)
	
	if _is_sliding and h_vel.length() < slide_min_speed and body.get_floor_angle() < slide_min_slope_angle:
		_is_sliding = false
	
	body.velocity.x = h_vel.x
	body.velocity.z = h_vel.z

func _handle_wall_run_state(delta: float) -> void:
	if not can_wall_run:
		_is_wall_running = false
		return
		
	if body.is_on_floor():
		_is_wall_running = false
		_wall_run_timer = 0.0
		return
		
	var h_vel := Vector3(body.velocity.x, 0, body.velocity.z)
	
	if body.is_on_wall() and h_vel.length() >= wall_run_min_speed and _wall_run_timer < wall_run_max_duration:
		var temp_normal = body.get_wall_normal()
		var entry_dot = h_vel.normalized().dot(temp_normal)
		
		# Only allow wall run if we hit it at an angle, not head-on
		if entry_dot > wall_run_angle_limit:
			if not _is_wall_running:
				_is_wall_running = true
			
			_wall_normal = temp_normal
			_wall_run_timer += delta
		else:
			_is_wall_running = false
	else:
		_is_wall_running = false
#endregion
