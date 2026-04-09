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


func ms_to_kmh(ms_value: float) -> float:
	return ms_value * 3.6

func kmh_to_ms(kmh_value: float) -> float:
	return kmh_value / 3.6

func exp_interp(a: float, b: float, t: float, k: float = 5.0) -> float:
	var weight = 1.0 - exp(-k * t)
	return lerp(a, b, weight)

func damp(source: float, target: float, lambda: float, delta: float):
	return lerp(source, target, 1 - exp(-lambda * delta))

func damp_vector(source: Vector2, target: Vector2, lambda: float, delta: float):
	var x = damp(source.x, target.x, lambda, delta)
	var y = damp(source.y, target.y, lambda, delta)
	
	return Vector2(x, y)
 
