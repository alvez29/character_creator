class_name ShakerComponent
extends Node
## Universal Shaker Component.
## Applies procedural noise-based shaking or discrete random shaking (Smash Bros style)
## to its target node. Supports Node3D, Camera3D, Node2D, and Camera2D.

signal on_shake_finished

@export var target_node: Node

## Default profile to use if a trauma is added without specifying one.
@export var default_profile: ShakeProfile

@export_group("Continuous Mode")
## If true, continuous shake will be applied (trauma never decays).
@export var is_continuous: bool = false
## The trauma level to maintain when continuous mode is active.
@export_range(0.0, 1.0) var continuous_trauma: float = 1.0

var trauma: float = 0.0
var _time: float = 0.0
var _trauma_tween: Tween

var _noise: FastNoiseLite

# State for restoring position correctly without drifting
var _last_pos_offset: Variant
var _last_rot_offset: Variant

enum TargetMode { NONE, NODE3D, NODE2D, CAMERA2D }
var _target_mode: TargetMode = TargetMode.NONE

func _ready() -> void:
	_noise = FastNoiseLite.new()
	_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	
	if not target_node:
		target_node = get_parent()
		
	_detect_target_mode()
	
	if _target_mode == TargetMode.NODE3D:
		_last_pos_offset = Vector3.ZERO
		_last_rot_offset = Vector3.ZERO
	elif _target_mode == TargetMode.NODE2D or _target_mode == TargetMode.CAMERA2D:
		_last_pos_offset = Vector2.ZERO
		_last_rot_offset = 0.0
	else:
		push_error("ShakerComponent: Target node is not a supported type (Node2D, Camera2D, Node3D, Camera3D).")
		set_process(false)

func _detect_target_mode() -> void:
	if target_node is Camera2D:
		_target_mode = TargetMode.CAMERA2D
	elif target_node is Node2D:
		_target_mode = TargetMode.NODE2D
	elif target_node is Node3D: # Covers both Node3D and Camera3D
		_target_mode = TargetMode.NODE3D


## Adds trauma to the shaker, causing it to shake.
## [param amount]: The intensity to add (0.0 to 1.0).
## [param profile]: An optional ShakeProfile to use for this shake. Overrides the default if provided.
func add_trauma(amount: float = 1.0, profile: ShakeProfile = null) -> void:
	if profile != null:
		default_profile = profile
		
	if default_profile == null:
		push_warning("ShakerComponent: Attempted to add trauma but no ShakeProfile is assigned.")
		return
		
	trauma = clampf(trauma + amount, 0.0, 1.0)
	
	# We use Tween to decay the trauma, which allows us to use juicy easing curves (bounce, elastic, sine)
	if _trauma_tween and _trauma_tween.is_running():
		_trauma_tween.kill()
		
	_trauma_tween = create_tween()
	_trauma_tween.tween_property(self, "trauma", 0.0, default_profile.duration)
	_trauma_tween.tween_callback(func(): on_shake_finished.emit())
	_trauma_tween.set_trans(default_profile.transition_type)
	_trauma_tween.set_ease(default_profile.ease_type)


func _process(delta: float) -> void:
	if not is_instance_valid(target_node) or default_profile == null:
		return
		
	
	if Input.is_key_pressed(KEY_6):
		add_trauma(1)
	
	var active_trauma: float = continuous_trauma if is_continuous else trauma
	
	# Restore initial state directly by subtracting the last evaluated offsets
	if _last_pos_offset != null and _last_rot_offset != null:
		_apply_offsets(_last_pos_offset, _last_rot_offset, false)
	
	if active_trauma > 0.0:
		_time += default_profile.frequency * delta
		var amount := active_trauma * active_trauma
		
		match _target_mode:
			TargetMode.NODE3D:
				var target_pos := Vector3.ZERO
				var target_rot := Vector3.ZERO
				
				if default_profile.shake_type == ShakeProfile.ShakeType.SMOOTH:
					target_pos = Vector3(
						_noise.get_noise_1d(_time) * default_profile.amplitude_x,
						_noise.get_noise_1d(_time + 1000.0) * default_profile.amplitude_y,
						_noise.get_noise_1d(_time + 2000.0) * default_profile.amplitude_z
					) * amount
					target_rot = Vector3(
						_noise.get_noise_1d(_time + 3000.0) * default_profile.rotation_x,
						_noise.get_noise_1d(_time + 4000.0) * default_profile.rotation_y,
						_noise.get_noise_1d(_time + 5000.0) * default_profile.rotation_z
					)
					
				elif default_profile.shake_type == ShakeProfile.ShakeType.SNAP:
					target_pos = Vector3(
						randf_range(-1.0, 1.0) * default_profile.amplitude_x,
						randf_range(-1.0, 1.0) * default_profile.amplitude_y,
						randf_range(-1.0, 1.0) * default_profile.amplitude_z
					) * amount
					target_rot = Vector3(
						randf_range(-1.0, 1.0) * default_profile.rotation_x,
						randf_range(-1.0, 1.0) * default_profile.rotation_y,
						randf_range(-1.0, 1.0) * default_profile.rotation_z
					)
				
				target_rot.x = deg_to_rad(target_rot.x * amount)
				target_rot.y = deg_to_rad(target_rot.y * amount)
				target_rot.z = deg_to_rad(target_rot.z * amount)
				
				_last_pos_offset = target_pos
				_last_rot_offset = target_rot
				
			TargetMode.NODE2D, TargetMode.CAMERA2D:
				var target_pos := Vector2.ZERO
				var target_rot := 0.0
				
				if default_profile.shake_type == ShakeProfile.ShakeType.SMOOTH:
					target_pos = Vector2(
						_noise.get_noise_1d(_time) * default_profile.amplitude_x,
						_noise.get_noise_1d(_time + 1000.0) * default_profile.amplitude_y
					) * amount
					var r = _noise.get_noise_1d(_time + 3000.0) * default_profile.rotation_z
					target_rot = deg_to_rad(r * amount)
					
				elif default_profile.shake_type == ShakeProfile.ShakeType.SNAP:
					target_pos = Vector2(
						randf_range(-1.0, 1.0) * default_profile.amplitude_x,
						randf_range(-1.0, 1.0) * default_profile.amplitude_y
					) * amount
					target_rot = deg_to_rad(randf_range(-1.0, 1.0) * default_profile.rotation_z * amount)
					
				_last_pos_offset = target_pos
				_last_rot_offset = target_rot
			
		_apply_offsets(_last_pos_offset, _last_rot_offset, true)
	else:
		_reset_offsets()


func _apply_offsets(pos_offset: Variant, rot_offset: Variant, add: bool = true) -> void:
	if not is_instance_valid(target_node):
		return
		
	var mult = 1.0 if add else -1.0
	
	match _target_mode:
		TargetMode.NODE3D, TargetMode.NODE2D:
			target_node.position += pos_offset * mult
			target_node.rotation += rot_offset * mult
		TargetMode.CAMERA2D:
			target_node.offset += pos_offset * mult
			target_node.rotation += rot_offset * mult


func _reset_offsets() -> void:
	match _target_mode:
		TargetMode.NODE3D:
			_last_pos_offset = Vector3.ZERO
			_last_rot_offset = Vector3.ZERO
		TargetMode.NODE2D, TargetMode.CAMERA2D:
			_last_pos_offset = Vector2.ZERO
			_last_rot_offset = 0.0
