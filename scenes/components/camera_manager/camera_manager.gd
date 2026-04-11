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
@export var base_fov: float = 75.0
@export var action_min_fov: float = 80.0
@export var action_max_fov: float = 100.0
@export var fov_max_speed_reference: float = 20.0
@export var fov_lerp_speed: float = 8.0

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


func adjust_dynamic_fov(delta: float, current_speed: float, is_action_state: bool):
	var current_base_fov = SettingsManager.fov if SettingsManager else base_fov
	
	if should_change_fov_by_speed:
		var target_fov = current_base_fov
		
		if is_action_state and current_speed > 1.0:
			var speed_factor = clamp(current_speed / fov_max_speed_reference, 0.0, 1.0)
			target_fov = lerp(action_min_fov, action_max_fov, speed_factor)
		
		camera.fov = Utils.damp(camera.fov, target_fov, fov_lerp_speed, delta)
	else:
		camera.fov = Utils.damp(camera.fov, current_base_fov, fov_lerp_speed, delta)

func active_camera():
	camera.current = true
	

func _on_zoom_lerp_timer_timeout() -> void:
	emit_signal("on_zoom_lerp_finished")
