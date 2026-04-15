## Data class that represents a single configuration or game setting mapping its visual definition to a system registry key.
class_name Setting
extends Resource

enum Section {
	VIDEO,
	CONTROLS,
	DEFAULT
}

@export var key: String = ""
@export var system_path: String = ""
@export var value: Variant
@export var section: Section


func _init(_key: String = "", _system_path: String = "", _section: Section = Section.DEFAULT, _value: Variant = null) -> void:
	key = _key
	system_path = _system_path
	section = _section
	value = _value
