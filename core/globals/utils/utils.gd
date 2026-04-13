extends Node

var Physics: PhysicsUtils = PhysicsUtils.new()
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

class PhysicsUtils:
	func intersect_ray(
		world: World3D, 
		origin: Vector3, 
		target: Vector3, 
		collision_mask: int = 0xFFFFFFFF, 
		exclude: Array[RID] = [],
		hit_from_inside: bool = false,
		hit_back_faces: bool = true
	) -> Dictionary:
		var query := PhysicsRayQueryParameters3D.create(origin, target)
		
		if not exclude.is_empty():
			query.exclude = exclude
		
		query.collision_mask = collision_mask
		query.hit_from_inside = hit_from_inside
		query.hit_back_faces = hit_back_faces
		
		return world.direct_space_state.intersect_ray(query)
	 
	func intersect_ray_multi(
		world: World3D,
		origin: Vector3,
		target: Vector3,
		max_results: int = 32,
		collision_mask: int = 0xFFFFFFFF,
		exclude: Array[RID] = []
	) -> Array[Dictionary]:
		var results: Array[Dictionary] = []
		var current_exclude: Array[RID] = exclude.duplicate()
		
		for i in max_results:
			var query := PhysicsRayQueryParameters3D.create(origin, target)
			query.exclude = current_exclude
			query.collision_mask = collision_mask
			
			var result := world.direct_space_state.intersect_ray(query)
			
			if result.is_empty():
				break
			
			results.append(result)
			current_exclude.append(result.rid)
		
		return results
	 
	func intersect_shape(
		world: World3D, 
		target: Vector3, 
		radius: float, 
		collision_mask: int = 0xFFFFFFFF,
		exclude: Array[RID] = []
	) -> Dictionary:
		var shape_rid := PhysicsServer3D.sphere_shape_create()
		PhysicsServer3D.shape_set_data(shape_rid, radius)
		
		var query := PhysicsShapeQueryParameters3D.new()
		query.transform.origin = target
		query.shape_rid = shape_rid
		query.exclude = exclude
		query.collision_mask = collision_mask
		
		var intersection := world.direct_space_state.intersect_shape(query, 1)
		
		PhysicsServer3D.free_rid(shape_rid)
		
		if intersection.is_empty():
			return {}
		else:
			return intersection[0]
	 
	func intersect_shape_with_point(
		world: World3D,
		target: Vector3,
		radius: float,
		collision_mask: int = 0xFFFFFFFF,
		exclude: Array[RID] = []
	) -> Dictionary:
		var shape_rid := PhysicsServer3D.sphere_shape_create()
		PhysicsServer3D.shape_set_data(shape_rid, radius)
		
		var query := PhysicsShapeQueryParameters3D.new()
		query.transform.origin = target
		query.shape_rid = shape_rid
		query.exclude = exclude
		query.collision_mask = collision_mask
		
		var result := world.direct_space_state.get_rest_info(query)
		
		PhysicsServer3D.free_rid(shape_rid)
		
		if result.is_empty():
			return {"collided": false}
			
		# get_rest_info does not return the collider object directly, only the id
		var collider_id: int = result.get("collider_id", 0)
		var collider: Object = instance_from_id(collider_id) if collider_id > 0 else null
		
		return {
			"collided": true,
			"point": result.get("point", Vector3.ZERO),
			"normal": result.get("normal", Vector3.ZERO),
			"collider": collider,
			"collider_id": collider_id,
			"rid": result.get("rid", RID()),
			"shape": result.get("shape", 0),
			"linear_velocity": result.get("linear_velocity", Vector3.ZERO)
		}
	 
	func intersect_shape_motion(
		world: World3D,
		from: Vector3,
		motion: Vector3,
		radius: float,
		collision_mask: int = 0xFFFFFFFF,
		exclude: Array[RID] = []
	) -> Dictionary:
		var shape_rid := PhysicsServer3D.sphere_shape_create()
		PhysicsServer3D.shape_set_data(shape_rid, radius)
		
		var query := PhysicsShapeQueryParameters3D.new()
		query.transform.origin = from
		query.shape_rid = shape_rid
		query.motion = motion
		query.exclude = exclude
		query.collision_mask = collision_mask
		
		var result := world.direct_space_state.cast_motion(query)
		
		PhysicsServer3D.free_rid(shape_rid)
		
		if result[1] > 0.0:
			var collision_point: Vector3 = from + (motion * result[0])
			return {
				"collided": true,
				"point": collision_point,
				"safe_fraction": result[0],
				"unsafe_fraction": result[1],
				"travel_distance": motion.length() * result[0]
			}
		
		return {"collided": false}
	 
	func intersect_shape_contacts(
		world: World3D,
		target: Vector3,
		radius: float,
		collision_mask: int = 0xFFFFFFFF,
		exclude: Array[RID] = [],
		max_contacts: int = 32
	) -> Array[Dictionary]:
		var shape_rid := PhysicsServer3D.sphere_shape_create()
		PhysicsServer3D.shape_set_data(shape_rid, radius)
		
		var query := PhysicsShapeQueryParameters3D.new()
		query.transform.origin = target
		query.shape_rid = shape_rid
		query.exclude = exclude
		query.collision_mask = collision_mask
		
		var contacts: PackedVector3Array = world.direct_space_state.collide_shape(query, max_contacts)
		
		PhysicsServer3D.free_rid(shape_rid)
		
		var results: Array[Dictionary] = []
		for i in range(0, contacts.size(), 2):
			results.append({
				"point_on_shape": contacts[i],
				"point_on_collider": contacts[i + 1] if i + 1 < contacts.size() else Vector3.ZERO
			})
		
		return results
	 
	func shape_cast(
		world: World3D,
		shape: Shape3D,
		from_transform: Transform3D,
		motion: Vector3,
		collision_mask: int = 0xFFFFFFFF,
		exclude: Array[RID] = []
	) -> Dictionary:
		var params := PhysicsShapeQueryParameters3D.new()
		params.shape = shape
		params.transform = from_transform
		params.motion = motion
		params.exclude = exclude
		params.collision_mask = collision_mask
		
		var result := world.direct_space_state.cast_motion(params)
		
		if result[1] > 0.0:
			var collision_point: Vector3 = from_transform.origin + (motion * result[0])
			return {
				"collided": true,
				"point": collision_point,
				"safe_fraction": result[0],
				"unsafe_fraction": result[1]
			}
		
		return {"collided": false}
	 
	func shape_query_info(
		world: World3D,
		shape: Shape3D,
		transform: Transform3D,
		collision_mask: int = 0xFFFFFFFF,
		exclude: Array[RID] = []
	) -> Dictionary:
		var params := PhysicsShapeQueryParameters3D.new()
		params.shape = shape
		params.transform = transform
		params.exclude = exclude
		params.collision_mask = collision_mask
		
		var result := world.direct_space_state.get_rest_info(params)
		
		if result.is_empty():
			return {"collided": false}
			
		# get_rest_info does not return the collider object directly, only the id
		var collider_id: int = result.get("collider_id", 0)
		var collider: Object = instance_from_id(collider_id) if collider_id > 0 else null
		
		return {
			"collided": true,
			"point": result.get("point", Vector3.ZERO),
			"normal": result.get("normal", Vector3.ZERO),
			"collider": collider,
			"collider_id": collider_id,
			"rid": result.get("rid", RID()),
			"shape": result.get("shape", 0)
		}
	 
	func has_line_of_sight(
		world: World3D,
		from: Vector3,
		to: Vector3,
		collision_mask: int = 0xFFFFFFFF,
		exclude: Array[RID] = []
	) -> bool:
		var result := intersect_ray(world, from, to, collision_mask, exclude)
		return result.is_empty()
	 
	func get_ground_point(
		world: World3D,
		position: Vector3,
		max_distance: float = 10.0,
		collision_mask: int = 0xFFFFFFFF
	) -> Dictionary:
		var from: Vector3 = position
		var to: Vector3 = position + Vector3.DOWN * max_distance
		
		var result := intersect_ray(world, from, to, collision_mask)
		
		if result.is_empty():
			return {"found": false}
		
		return {
			"found": true,
			"point": result.position,
			"normal": result.normal,
			"distance": from.distance_to(result.position),
			"collider": result.collider
		}
	 
	func is_on_ground(
		world: World3D,
		position: Vector3,
		radius: float = 0.5,
		check_distance: float = 0.1,
		collision_mask: int = 0xFFFFFFFF
	) -> bool:
		var result := intersect_shape_with_point(
			world,
			position + Vector3.DOWN * check_distance,
			radius,
			collision_mask
		)
		
		return result.get("collided", false)
	 
	func get_objects_in_radius(
		world: World3D,
		center: Vector3,
		radius: float,
		collision_mask: int = 0xFFFFFFFF,
		exclude: Array[RID] = []
	) -> Array[Dictionary]:
		var shape_rid := PhysicsServer3D.sphere_shape_create()
		PhysicsServer3D.shape_set_data(shape_rid, radius)
		
		var query := PhysicsShapeQueryParameters3D.new()
		query.transform.origin = center
		query.shape_rid = shape_rid
		query.exclude = exclude
		query.collision_mask = collision_mask
		
		var raw_results := world.direct_space_state.intersect_shape(query, 32)
		var results: Array[Dictionary] = []
		
		for item in raw_results:
			results.append(item as Dictionary)
		
		PhysicsServer3D.free_rid(shape_rid)
		
		return results

	func apply_central_impulse(target: Node3D, impulse: Vector3, velocity_change: bool = false, target_mass: float = 0.001) -> void:
		var final_mass: float = target.mass if "mass" in target else target_mass
		
		if final_mass <= 0.001:
			return
		
		if "velocity" in target:
			if velocity_change:
				target.velocity += impulse
			else:
				target.velocity += impulse / final_mass
		
	func apply_central_force(target: Node3D, force: Vector3, delta: float, target_mass: float = 0.0001) -> void:
		var final_mass: float = target.mass if "mass" in target else target_mass
		
		if final_mass <= 0.001:
			return
		
		if "velocity" in target:
			target.velocity += (force / final_mass) * delta

func get_child_of_type_recursive(subject: Node, type: Variant) -> Node:
	for child in subject.get_children():
		if is_instance_of(child, type):
			return child
		var result := get_child_of_type_recursive(child, type)
		if result:
			return result
	return null

func ms_to_kmh(ms_value: float) -> float:
	return ms_value * 3.6

func kmh_to_ms(kmh_value: float) -> float:
	return kmh_value / 3.6

func exp_interp(a: float, b: float, t: float, k: float = 5.0) -> float:
	var weight: float = 1.0 - exp(-k * t)
	return lerp(a, b, weight)

func damp(source: float, target: float, lambda: float, delta: float) -> float:
	return lerp(source, target, 1.0 - exp(-lambda * delta))

func damp_vector(source: Vector2, target: Vector2, lambda: float, delta: float) -> Vector2:
	var x: float = damp(source.x, target.x, lambda, delta)
	var y: float = damp(source.y, target.y, lambda, delta)
	
	return Vector2(x, y)

func get_max_jump_height(jump_velocity: float, gravity: float) -> float:
	return jump_velocity * jump_velocity / (2.0 * gravity)
 
