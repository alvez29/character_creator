extends Node

signal config_saved_correctly
signal config_loaded_from_file_system

@export var exposed_settings: SettingsSet = preload("uid://crsewa8vhll4j")
@export var apply_private_settings_on_start = true
@export var config_file_path = "user://game_config.cfg"
@export var should_override_project_settings: bool = false

## Settings that are used in _process or need to be updated quickly
#region Quick Access Settings
var mouse_sensitivity: float = 0.0
#endregion


var config_id_to_section = {
	"resolution_width": Setting.Section.VIDEO,
	"resolution_height": Setting.Section.VIDEO,
	"window_mode": Setting.Section.VIDEO,
	"mouse_sensitivity": Setting.Section.CONTROLS
}

var config_id_system_path = {
	"resolution_width": "display/window/size/viewport_width",
	"resolution_height": "display/window/size/viewport_height",
	"window_mode": "display/window/size/mode",
}


func _ready() -> void:
	try_load_settings_from_file_system()


#region Load
func try_load_settings_from_file_system():
	var config = ConfigFile.new()
	var err = config.load(config_file_path)

	if err != OK:
		push_warning("[Settings] Config not found, creating new one")
		save_config_file()
		_apply_all_settings()
		config_loaded_from_file_system.emit()
		return

	for config_section in config.get_sections():
		for config_section_key in config.get_section_keys(config_section):
			var value = config.get_value(config_section, config_section_key)

			var system_path = config_id_system_path.get(config_section_key, "")
			var section = config_id_to_section.get(config_section_key, Setting.Section.DEFAULT)

			var setting := Setting.new(config_section_key, system_path, section, value)
			exposed_settings.add_setting(setting)

	_apply_all_settings()
	config_loaded_from_file_system.emit()
#endregion


#region Apply
func _apply_all_settings():
	for setting in exposed_settings.settings:
		_apply_setting(setting)


func _apply_setting(setting: Setting):
	var is_system_setting = not setting.system_path.is_empty()

	if is_system_setting and should_override_project_settings:
		ProjectSettings.set_setting(setting.system_path, setting.value)
		ProjectSettings.save()
	else:
		match setting.key:
			"mouse_sensitivity":
				mouse_sensitivity = setting.value
			_:
				push_warning("[Settings] Unknown local setting: %s" % setting.key)
#endregion


#region Getters
func get_setting(key: String, type: SettingsSet.Type = SettingsSet.Type.EXPOSED) -> Variant:
	match type:
		SettingsSet.Type.EXPOSED:
			return exposed_settings.get_setting_value(key)
	return null
#endregion


#region Save
func save_config_file(type: SettingsSet.Type = SettingsSet.Type.EXPOSED):
	var config_file = ConfigFile.new()
	var setting_set = exposed_settings

	for setting in setting_set.settings:
		var section = "other"

		match setting.section:
			Setting.Section.VIDEO:
				section = "video"
			Setting.Section.CONTROLS:
				section = "controls"

		config_file.set_value(section, setting.key, setting.value)

	var err = config_file.save(config_file_path)

	if err != OK:
		push_warning("[Settings] Could not save config: %s" % config_file_path)
	else:
		config_saved_correctly.emit()
#endregion


func map_config_section_string_to_enum(section_as_string: String) -> Setting.Section:
	return Setting.Section.get(section_as_string, Setting.Section.DEFAULT)
