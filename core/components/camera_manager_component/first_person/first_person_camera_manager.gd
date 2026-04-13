## Component that manages a First Person Camera behaviors.
## Handles dynamic zooming, FOV interpolation, and procedural camera shake based on trauma.
class_name FirstPersonCameraManager
extends Node

signal on_zoom_lerp_finished

@export var debug := false

@export var camera: Camera3D

@onready var zoom_lerp_timer = %ZoomLerpTimer

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



func _process(delta: float) -> void:
	_try_process_tilt(delta)
	
	camera.rotation.z = _current_tilt


func set_camera_zoom(target_zoom, lerp_duration: float):
	_target_zoom = target_zoom
	_zoom_lerp_speed = 1 / lerp_duration
	zoom_lerp_timer.stop()
	zoom_lerp_timer.start(lerp_duration)


func lerp_camera_zoom(alpha: float, target_zoom: Vector2):
	camera.zoom.x = lerpf(camera.zoom.x, target_zoom.x, alpha)
	camera.zoom.y = lerpf(camera.zoom.y, target_zoom.y, alpha)
	_current_camera_zoom = camera.zoom


func _try_process_tilt(delta):
	if _target_tilt != _current_tilt:
		_current_tilt = Utils.exp_interp(_current_tilt, _target_tilt, delta, tilt_speed)


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
