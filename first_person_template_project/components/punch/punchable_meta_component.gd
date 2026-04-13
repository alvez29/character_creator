class_name PunchableComponent
extends MetaComponent

static var punchable_meta_key = &"punchable"

static func get_puchable_component_or_null(subject):
	return subject.get_meta(punchable_meta_key) if subject.has_meta(punchable_meta_key) else null

func get_related_meta() -> StringName:
	return punchable_meta_key

func punch(target_position: Vector3, punch_origin: Vector3, impulse: float = 20.0, torque: Vector3 = Vector3.ZERO):
	if target_body is RigidBody3D:
		var direction = (target_position - punch_origin).normalized()
		Utils
		target_body.linear_velocity += direction * impulse / target_body.mass
		target_body.angular_velocity += torque * impulse / target_body.mass
