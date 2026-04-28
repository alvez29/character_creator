class_name MeshSelectSetting
extends SelectSetting

@export var options: Array[MeshOption]


func load() -> void:
	_build_map_from(options)


func get_default_id() -> String:
	return options[0].id if not options.is_empty() else &""


func get_options() -> Array:
	return options


## Returns the MeshOption for the given id, or null if not found.
func find_mesh(id: String) -> MeshOption:
	return _map.get(id, null) as MeshOption
