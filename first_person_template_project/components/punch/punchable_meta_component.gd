class_name PunchableComponent
extends MetaComponent

static var punchable_meta_key = &"punchable"

@export
var impulse_factor: float = 1

static func get_puchable_component_or_null(subject):
	return subject.get_meta(punchable_meta_key) if subject.has_meta(punchable_meta_key) else null

func get_related_meta() -> StringName:
	return punchable_meta_key

func punch(target_position: Vector3, punch_direction: Vector3, impulse: float = 20.0, torque: Vector3 = Vector3.ZERO):
	if target_body is RigidBody3D:
		# Calculate the hit direction directly from the passed vector
		var direction = punch_direction.normalized()
		
		var offset = target_position - target_body.global_position
		
		# Godot's apply_impulse naturally simulates REAL WORLD torque when offset is provided!
		target_body.apply_impulse(direction * impulse * impulse_factor, offset)
