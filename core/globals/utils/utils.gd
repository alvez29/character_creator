extends Node

var Physics = PhysicsUtils.new()

class PhysicsUtils:
	func intersect_ray(world: World3D, origin, target, collision_mask = null, exclude: Array[RID] = []) -> Dictionary:
		var query := PhysicsRayQueryParameters3D.create(origin, target)
		
		if not exclude.is_empty():
			query.exclude = exclude
		
		if collision_mask:
			query.collision_mask = collision_mask
		
		return world.direct_space_state.intersect_ray(query)


	func intersect_shape(world: World3D, target: Vector3, radius: float, collision_mask = null) -> Dictionary:
		var shape_rid = PhysicsServer3D.sphere_shape_create()
		PhysicsServer3D.shape_set_data(shape_rid, radius)

		var query = PhysicsShapeQueryParameters3D.new()
		query.transform.origin = target
		query.shape_rid = shape_rid
		
		query.exclude = [self]
		
		if collision_mask:
			query.collision_mask = collision_mask
		
		var intersection = world.direct_space_state.intersect_shape(query, 1)
		
		if intersection.is_empty():
			return { }
		else:
			return intersection[0]


	func apply_central_impulse(target: Node3D, impulse: Vector3, velocity_change: bool = false, target_mass: float = 0.001):
		var final_mass
		
		if target.mass:
			final_mass = target.mass
		elif final_mass > 0.001:
			final_mass = target_mass
		else:
			return
		
		if target.velocity:
			if velocity_change:
				target.velocity += impulse
			else:
				target.velocity += impulse / target_mass
		
	func apply_central_force(target: Node3D, force: Vector3, delta: float, target_mass: float = 0.0001):
		var final_mass
		
		if target.mass:
			final_mass = target.mass
		elif final_mass > 0.001:
			final_mass = target_mass
		else:
			return
		
		if target.velocity:
			target.velocity += (force / target_mass) * delta

func get_child_of_type_recursive(subject: Node, type):
	for child in subject.get_children():
		if is_instance_of(child, type):
			return child
		var result = child.get_child_of_type_recursive(type)
		if result:
			return result
	return null


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


func get_max_jump_height(jump_velocity, gravity) -> float:
	return jump_velocity * jump_velocity / (2 * gravity)
 
