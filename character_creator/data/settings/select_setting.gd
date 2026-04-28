## Abstract base for settings that present a fixed palette of options,
## each identified by a stable string ID.
##
## Subclasses declare a typed @export var options: Array[MyOption] and
## implement load() by calling _build_map_from(options).
## The _map is then used for O(1) lookup via find().
@abstract
class_name SelectSetting
extends CharacterSetting

## Internal lookup map built at runtime. Key = SelectOption.id.
var _map: Dictionary[String, SelectOption]


## Returns the option with the given id, or null if not found.
func find(id: String) -> SelectOption:
	return _map.get(id, null)


## Returns the id of the first option, or "" if no options exist.
## Subclasses should override this to access their typed array.
@abstract
func get_default_id() -> String


## Returns the options array. Used by the UI to iterate options generically.
@abstract
func get_options() -> Array


## Shared map-building logic for all SelectSetting subclasses.
## Pass the subclass's typed options array — GDScript accepts typed arrays
## as untyped Array parameters, so covariance is handled at the call site.
func _build_map_from(options: Array) -> void:
	_map.clear()
	for item in options:
		var option := item as SelectOption
		if not option:
			push_warning("%s: entry is not a SelectOption, skipping." % get_class())
			continue
		if option.id.is_empty():
			push_warning("%s: option '%s' has an empty id and will be skipped." % [get_class(), option.display_name])
			continue
		if _map.has(option.id):
			push_warning("%s: duplicate id '%s' — only the first entry will be used." % [get_class(), option.id])
			continue
		_map[option.id] = option
