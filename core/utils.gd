extends Node

func get_child_of_type_recursive(subject: Node, type):
	for child in subject.get_children():
		if is_instance_of(child, type):
			return child
		var result = child.get_child_of_type_recursive(type)
		if result:
			return result
	return null

func _cast_ray(world, origin, target, collision_mask = null) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(origin, target)
	query.exclude = [self]
	
	if collision_mask:
		query.collision_mask = collision_mask
	
	return world.direct_space_state.intersect_ray(query)
