## Data resource representing an exposed settings set containing setting objects dynamically configured.
class_name SettingsSet
extends Resource

enum Type {
	EXPOSED
}

@export var settings: Array[Setting] = []


static func get_empty_set() -> SettingsSet:
	return SettingsSet.new()


func clear():
	settings.clear()


func add_setting(setting: Setting):
	var existing := get_setting_by_key(setting.key)
	if existing:
		existing.value = setting.value
	else:
		settings.append(setting)


func get_setting_by_key(key: String) -> Setting:
	for setting in settings:
		if setting.key == key:
			return setting
	return null


func get_setting_value(key: String) -> Variant:
	var setting = get_setting_by_key(key)
	if setting:
		return setting.value
	return null
