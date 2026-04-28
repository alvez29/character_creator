class_name CharacterCreatorUI
extends Node

var character_data: CharacterData
var profile: CharacterCreationProfile

var _range_widget_scene = preload("uid://b21hvrtt462hr")
var _options_widget_scene = preload("uid://du65tq3c0hmov")

@export_category("Eyes")
@export var eyes_settings_container: Control

@export_category("Mouth")
@export var mouth_settings_container: Control

@export_category("Skin")
@export var skin_settings_container: Control


func initialize(manager_ref: CharacterCreatorManager) -> void:
	self.character_data = manager_ref.character_data
	self.profile = manager_ref.creation_profile

	initialize_eyes_settings()
	initialize_mouth_settings()
	initialize_skin_settings()


func initialize_eyes_settings():
	load_range_setting(profile.eyes_size, character_data.eyes_size)
	load_range_setting(profile.eyes_separation, character_data.eyes_separation)
	load_range_setting(profile.eyes_rotation, character_data.eyes_rotation)
	load_range_setting(profile.eyes_height, character_data.eyes_height)
	load_options_setting(profile.eyes_textures, character_data.eye_texture)


func initialize_mouth_settings():
	load_range_setting(profile.mouth_size, character_data.mouth_size)



func initialize_skin_settings():
	load_options_setting(profile.skin_colors, character_data.skin_color)


func get_parent_container_by_type(type: CharacterSetting.Category):
	match type:
		CharacterSetting.Category.EYES:
			return eyes_settings_container
		CharacterSetting.Category.MOUTH:
			return mouth_settings_container
		CharacterSetting.Category.SKIN:
			return skin_settings_container
		_:  return eyes_settings_container


func load_range_setting(setting: CharacterSetting, data: Reactive):
	var parent_container = get_parent_container_by_type(setting.category)
	var range_widget_instance
	
	if not _range_widget_scene.can_instantiate():
		return
	
	range_widget_instance = _range_widget_scene.instantiate() as RangeWidget	
	parent_container.add_child(range_widget_instance)
	range_widget_instance.load_setting(setting, data)


func load_options_setting(setting: CharacterSetting, data: Reactive):
	var parent_container = get_parent_container_by_type(setting.category)
	var option_widget_instance
	
	if not _options_widget_scene.can_instantiate():
		return
	
	option_widget_instance = _options_widget_scene.instantiate()
	parent_container.add_child(option_widget_instance)
	option_widget_instance.load_setting(setting, data)
