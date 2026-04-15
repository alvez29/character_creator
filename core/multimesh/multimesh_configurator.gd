## Editor tool that allows creating, editing, and distributing instances within a MultiMeshInstance3D from the inspector.
@tool
extends MultiMeshInstance3D

var _is_updating: bool = false

@export var instances_positions: Array[Vector3] = []:
	set(v):
		instances_positions = v
		_try_apply()

@export var instances_rotations: Array[Vector3] = []:
	set(v):
		instances_rotations = v
		_try_apply()

@export var instances_scales: Array[Vector3] = []:
	set(v):
		instances_scales = v
		_try_apply()

@export_group("Random")
@export var random_area_size: Vector3 = Vector3(10.0, 0.0, 10.0)
@export var random_rotation_y_only: bool = true
@export var random_scale_min: float = 0.8
@export var random_scale_max: float = 1.2

func _try_apply():
	if Engine.is_editor_hint() and not _is_updating:
		apply_to_multimesh()

@export_tool_button("Init Array", "Breakpoint")
var init_array = func initialize_array():
	if not multimesh:
		push_error("Asigna un MultiMesh primero")
		return
	
	_is_updating = true
	instances_positions = []
	instances_rotations = []
	instances_scales = []
	for i in range(multimesh.instance_count):
		instances_positions.append(Vector3.ZERO)
		instances_rotations.append(Vector3.ZERO)
		instances_scales.append(Vector3.ONE)
	_is_updating = false
	
	apply_to_multimesh()

@export_tool_button("Apply Multimesh", "CodeRegionFoldedRightArrow")
var apply_multimesh = func():
	apply_to_multimesh()

func apply_to_multimesh():
	if not multimesh:
		return
	
	if instances_positions.size() != multimesh.instance_count or instances_rotations.size() != multimesh.instance_count or instances_scales.size() != multimesh.instance_count:
		return
	
	for i in range(multimesh.instance_count):
		var pos = instances_positions[i]
		var rot = instances_rotations[i]
		var sca = instances_scales[i]
		
		var b = Basis.from_euler(Vector3(deg_to_rad(rot.x), deg_to_rad(rot.y), deg_to_rad(rot.z)))
		b = b.scaled(sca)
		multimesh.set_instance_transform(i, Transform3D(b, pos))

@export_tool_button("Write Multimesh", "Edit")
var read_from = func read_from_multimesh():
	if not multimesh:
		push_error("No MultiMesh")
		return
	
	_is_updating = true
	instances_positions = []
	instances_rotations = []
	instances_scales = []
	for i in range(multimesh.instance_count):
		var t = multimesh.get_instance_transform(i)
		instances_positions.append(t.origin)
		
		instances_scales.append(t.basis.get_scale())
		
		var euler = t.basis.get_euler()
		instances_rotations.append(Vector3(rad_to_deg(euler.x), rad_to_deg(euler.y), rad_to_deg(euler.z)))
	_is_updating = false
	
@export_tool_button("Add Instance", "Add")
var add_instance = func():
	if not multimesh:
		return
	
	multimesh.instance_count += 1
	_is_updating = true
	instances_positions.append(Vector3.ZERO)
	instances_rotations.append(Vector3.ZERO)
	instances_scales.append(Vector3.ONE)
	_is_updating = false
	apply_to_multimesh()

@export_tool_button("Reduce Instance", "Remove")
var remove_instance = func():
	if not multimesh or multimesh.instance_count == 0:
		return
	
	multimesh.instance_count -= 1
	_is_updating = true
	if instances_positions.size() > 0:
		instances_positions.pop_back()
	if instances_rotations.size() > 0:
		instances_rotations.pop_back()
	if instances_scales.size() > 0:
		instances_scales.pop_back()
	_is_updating = false
	apply_to_multimesh()

@export_tool_button("Random Distribute", "RandomNumberGenerator")
var distribute_random = func():
	if not multimesh or multimesh.instance_count == 0:
		return
	
	_is_updating = true
	
	if instances_positions.size() != multimesh.instance_count:
		instances_positions.resize(multimesh.instance_count)
		instances_rotations.resize(multimesh.instance_count)
		instances_scales.resize(multimesh.instance_count)
		
	for i in range(multimesh.instance_count):
		var x = randf_range(-random_area_size.x / 2.0, random_area_size.x / 2.0)
		var y = randf_range(-random_area_size.y / 2.0, random_area_size.y / 2.0)
		var z = randf_range(-random_area_size.z / 2.0, random_area_size.z / 2.0)
		instances_positions[i] = Vector3(x, y, z)
		
		if random_rotation_y_only:
			instances_rotations[i] = Vector3(0, randf_range(0, 360), 0)
		else:
			instances_rotations[i] = Vector3(randf_range(0, 360), randf_range(0, 360), randf_range(0, 360))
			
		var s = randf_range(random_scale_min, random_scale_max)
		instances_scales[i] = Vector3(s, s, s)
		
	_is_updating = false
	apply_to_multimesh()
