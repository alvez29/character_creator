## Component that manages a First Person Camera behaviors.
## Handles dynamic zooming, FOV interpolation, and procedural camera shake based on trauma.
class_name FirstPersonCameraManager
extends Node

signal on_zoom_lerp_finished

@export var debug := false

@export var camera: Camera3D

@onready var zoom_lerp_timer = %ZoomLerpTimer

@export_category("Camera Shake")
@export var decay: float = 1
@export var max_offset := Vector2(1, 1)
@export var max_roll: float = 0
@export var trauma_power: float = 2
@export var max_trauma: float = 2

@export_category("Camera Tilt")
@export var tilt_angle: float = 1.5
@export var tilt_speed: float = 8.0
@export var should_tilt: bool = true

@export_category("Camera FOV")
@export var should_change_fov_by_speed := true
@export var max_fov_speed: float = 20.0
@export var max_fov_addition_possible: float = 20

#region Zoom
var _current_camera_zoom = Vector2(1, 1)
var _current_tilt: float = 0.0
var _target_tilt: float = 0.0
var _target_zoom = Vector2(1, 1)
var _zoom_lerp_speed = 1.0
#endregion


#region Camera Shake
var _trauma: float = 0.0
var _continuous_trauma: float = 0.0
var _shake_tilt: float = 0.0
#endregion

#region FOV
var fov_addition: float = 0.0
#endregion

func _process(delta: float) -> void:
	_try_process_shake(delta)
	_try_process_tilt(delta)
	
	camera.rotation.z = _current_tilt + _shake_tilt
	
	if debug and Input.is_key_pressed(KEY_0):
		set_continuous_shake(true)


func set_camera_zoom(target_zoom, lerp_duration: float):
	_target_zoom = target_zoom
	_zoom_lerp_speed = 1 / lerp_duration
	zoom_lerp_timer.stop()
	zoom_lerp_timer.start(lerp_duration)


func lerp_camera_zoom(alpha: float, target_zoom: Vector2):
	camera.zoom.x = lerpf(camera.zoom.x, target_zoom.x, alpha)
	camera.zoom.y = lerpf(camera.zoom.y, target_zoom.y, alpha)
	_current_camera_zoom = camera.zoom


func add_trauma(trauma_addition: float):
	_trauma = clamp(_trauma + trauma_addition, 0.0, max_trauma)


func set_continuous_shake(active: bool, amount: float = 1.0):
	if active:
		_continuous_trauma = clamp(amount, 0.0, max_trauma)
	else:
		_continuous_trauma = 0.0


func _try_process_shake(delta):
	var effective_trauma = max(_trauma, _continuous_trauma)
	
	if effective_trauma > 0.0:
		if _trauma > 0.0:
			_trauma = max(_trauma - decay * delta, 0.0)
		_shake(effective_trauma)
	elif camera.h_offset != 0.0 or camera.v_offset != 0.0 or _shake_tilt != 0.0:
		camera.h_offset = 0.0
		camera.v_offset = 0.0
		_shake_tilt = 0.0


func _try_process_tilt(delta):
	if _target_tilt != _current_tilt:
		_current_tilt = Utils.exp_interp(_current_tilt, _target_tilt, delta, tilt_speed)


func _shake(trauma_to_use: float):
	var amount = pow(trauma_to_use / max_trauma, trauma_power)
	camera.h_offset = max_offset.x * amount * randf_range(-1.0, 1.0)
	camera.v_offset = max_offset.y * amount * randf_range(-1.0, 1.0)
	_shake_tilt = deg_to_rad(max_roll * amount * randf_range(-1.0, 1.0))


func tilt(input: float, delta: float):
	if should_tilt:
		var desired_tilt := deg_to_rad(-tilt_angle) * input
		_target_tilt = desired_tilt


func adjust_fov_by_speed(delta: float, speed):
	if should_change_fov_by_speed:
		var min_fov = 70
		var max_fov = 90
		var max_speed = 20
		
		var target_fov = lerp(min_fov, max_fov, clamp(speed / max_speed, 0, 1))
		
		fov_addition = lerp(fov_addition, target_fov - SettingsManager.fov, 5 * delta)
		camera.fov = SettingsManager.fov + fov_addition

func active_camera():
	camera.current = true
	

func _on_zoom_lerp_timer_timeout() -> void:
	emit_signal("on_zoom_lerp_finished")
