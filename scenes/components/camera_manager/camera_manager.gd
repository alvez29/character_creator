class_name FirstPersonCameraManager
extends Node

signal on_zoom_lerp_finished

@export var debug := false

@export var camera: Camera3D

@onready var zoom_lerp_timer = %ZoomLerpTimer

#region Camera Shake export
@export var decay: float = 1
@export var max_offset := Vector2(1, 1)
@export var max_roll: float = 0
@export var trauma_power: float = 2
@export var max_trauma: float = 2
#endregion

#region Zoom
var _current_camera_zoom = Vector2(1, 1)
var _target_zoom = Vector2(1, 1)
var _zoom_lerp_speed = 1.0
#endregion


#region Camera Shake
var _trauma: float = 0.0
#endregion


func _process(delta: float) -> void:
	_try_process_shake(delta)
	
	if debug and Input.is_key_pressed(KEY_0):
		add_trauma(0.1)


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


func _exp_interp(a: float, b: float, t: float, k: float = 5.0) -> float:
	var weight = 1.0 - exp(-k * t)
	return lerp(a, b, weight)


func _try_process_shake(delta):
	if _trauma > 0.0:
		_trauma = max(_trauma - decay * delta, 0.0)
		_shake()
	elif camera.h_offset != 0.0 or camera.v_offset != 0.0 or camera.rotation_degrees.z != 0.0:
		camera.h_offset = 0.0
		camera.v_offset = 0.0
		camera.rotation_degrees.z = 0.0


func _shake():
	var amount = pow(_trauma / max_trauma, trauma_power)
	camera.h_offset = max_offset.x * amount * randf_range(-1.0, 1.0)
	camera.v_offset = max_offset.y * amount * randf_range(-1.0, 1.0)
	camera.rotation_degrees.z = max_roll * amount * randf_range(-1.0, 1.0)


func _on_zoom_lerp_timer_timeout() -> void:
	emit_signal("on_zoom_lerp_finished")
