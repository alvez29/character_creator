## Component that allows a RigidBody3D to be grabbed by a player.
## It automatically registers itself into the target body's metadata for O(1) lookups.
class_name GrabbableComponent
extends MetaComponent

static var grabbable_meta_key = &"grabbable"

static func get_grabbable_component_or_null(subject):
	return subject.get_meta(grabbable_meta_key) if subject.has_meta(grabbable_meta_key) else null

func get_related_meta() -> StringName:
	return grabbable_meta_key

func grab():
	if target_body is RigidBody3D:
		target_body.linear_velocity = Vector3.ZERO
		target_body.angular_velocity = Vector3.ZERO
		target_body.can_sleep = false

func release():
	if target_body is RigidBody3D:
		target_body.can_sleep = true
