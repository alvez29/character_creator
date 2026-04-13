class_name SmoothShakeComponent
extends Node

## Componente modular que aplica sacudidas mediante ruido procedural (FastNoiseLite).
## Se puede vincular a cualquier Node3D, y modificará el FOV si es una Camera3D.

@export var target_node: Node

@export var noise: FastNoiseLite

@export_group("Shake Amplitudes")
@export var amplitude_translation := Vector3(0.1, 0.1, 0.1)
@export var amplitude_rotation := Vector3(0.05, 0.05, 0.05)
@export var amplitude_fov := 2.0

@export_group("Shake Properties")
@export var frequency := 15.0
@export var decay_rate := 1.5
@export var trauma_power := 2.0

var trauma: float = 0.0
var _time: float = 0.0

var _last_translation_offset := Vector3.ZERO
var _last_rotation_offset := Vector3.ZERO
var _last_fov_offset := 0.0


func _ready() -> void:
	if not noise:
		noise = FastNoiseLite.new()
		noise.noise_type = FastNoiseLite.TYPE_PERLIN
		noise.frequency = 0.1


func add_trauma(amount: float) -> void:
	trauma = clampf(trauma + amount, 0.0, 1.0)


func _get_active_target() -> Node:
	if is_instance_valid(target_node):
		return target_node
	return get_parent()


func _process(delta: float) -> void:
	var target = _get_active_target()
	
	if not is_instance_valid(target) or not target is Node3D:
		return
		
	target.position -= _last_translation_offset
	target.rotation -= _last_rotation_offset
	
	if target is Camera3D:
		target.fov -= _last_fov_offset
		
	if trauma > 0.0:
		trauma = maxf(trauma - decay_rate * delta, 0.0)
		
	if trauma > 0.0:
		_time += frequency * delta
		var amount := pow(trauma, trauma_power)
		
		_last_translation_offset = Vector3(
			noise.get_noise_1d(_time) * amplitude_translation.x,
			noise.get_noise_1d(_time + 1000.0) * amplitude_translation.y,
			noise.get_noise_1d(_time + 2000.0) * amplitude_translation.z
		) * amount
		
		_last_rotation_offset = Vector3(
			noise.get_noise_1d(_time + 3000.0) * amplitude_rotation.x,
			noise.get_noise_1d(_time + 4000.0) * amplitude_rotation.y,
			noise.get_noise_1d(_time + 5000.0) * amplitude_rotation.z
		) * amount
		
		if target is Camera3D:
			_last_fov_offset = noise.get_noise_1d(_time + 6000.0) * amplitude_fov * amount
			
	else:
		_last_translation_offset = Vector3.ZERO
		_last_rotation_offset = Vector3.ZERO
		_last_fov_offset = 0.0

	target.position += _last_translation_offset
	target.rotation += _last_rotation_offset
	
	if target is Camera3D:
		target.fov += _last_fov_offset
