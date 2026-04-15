## Procedural shake component that uses noise functions to generate dynamic trauma-based position and rotation offsets.
class_name ShakeComponent
extends Node

@export var target_node: Node

@export var noise: FastNoiseLite

@export_group("Shake Amplitudes")
@export var amplitude_translation := Vector3(0.1, 0.1, 0.1)
@export var amplitude_rotation := Vector3(0.05, 0.05, 0.05)

@export_group("Shake Properties")
@export var frequency := 15.0
@export var decay_rate := 1.5
@export var trauma_power := 2.0

var trauma: float = 0.0
var _time: float = 0.0

var is_shaking: bool = false
var continuous_trauma_level: float = 1.0

var _last_translation_offset := Vector3.ZERO
var _last_rotation_offset := Vector3.ZERO


func _ready() -> void:
	if not noise:
		noise = FastNoiseLite.new()
		noise.noise_type = FastNoiseLite.TYPE_PERLIN
		noise.frequency = 0.1


func add_trauma(amount: float) -> void:
	trauma = clampf(trauma + amount, 0.0, 1.0)


func start_shake(trauma_level: float = 1.0) -> void:
	continuous_trauma_level = clampf(trauma_level, 0.0, 1.0)
	is_shaking = true


func stop_shake() -> void:
	is_shaking = false


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
	
	if is_shaking:
		trauma = continuous_trauma_level
	elif trauma > 0.0:
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
			
	else:
		_last_translation_offset = Vector3.ZERO
		_last_rotation_offset = Vector3.ZERO

	target.position += _last_translation_offset
	target.rotation += _last_rotation_offset
