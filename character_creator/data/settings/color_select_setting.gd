## Setting for selecting a Color from a fixed palette of ColorOptions.
## Each option has a stable string ID used for serialization in CharacterData.
class_name ColorSelectSetting
extends SelectSetting

@export var options: Array[ColorOption]


func load() -> void:
	_build_map_from(options)


func get_default_id() -> String:
	return options[0].id if not options.is_empty() else ""


func get_options() -> Array:
	return options


## Returns the ColorOption for the given id, or null if not found.
func find_color(id: String) -> ColorOption:
	return _map.get(id, null) as ColorOption
