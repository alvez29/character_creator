## Setting for selecting a Texture2D from a fixed palette of TextureOptions.
## Each option has a stable string ID used for serialization in CharacterData.
class_name TextureSelectSetting
extends SelectSetting

@export var options: Array[TextureOption]


func load() -> void:
	_build_map_from(options)


func get_default_id() -> String:
	return options[0].id if not options.is_empty() else &""


func get_options() -> Array:
	return options


## Returns the TextureOption for the given id, or null if not found.
func find_texture(id: String) -> TextureOption:
	return _map.get(id, null) as TextureOption
