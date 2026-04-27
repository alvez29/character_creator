class_name CharacterCreatorUI
extends Control

var character_data: CharacterData
var settings: CharacterCreationSettings

@export_category("Eyes")
@export var eyes_size_slider: HSlider
@export var eyes_separation_slider: HSlider
@export var eyes_rotation_slider: HSlider
@export var eyes_height_slider: HSlider

@export_category("Skin")
@export var skin_color_picker: ColorPicker


func initialize(manager_ref: CharacterCreatorManager) -> void:
	self.character_data = manager_ref.character_data
	self.settings = manager_ref.creation_settings
	
	bind_signals()
	bind_settings()


func bind_settings():
	initialize_value_slider(eyes_size_slider, settings.eyes_size_steps)
	initialize_value_slider(eyes_separation_slider, settings.eyes_separation_steps)
	initialize_value_slider(eyes_rotation_slider, settings.eyes_rotation_steps)
	initialize_value_slider(eyes_height_slider, settings.eyes_height_steps)
	
	initialize_item_list()

func bind_signals():
	if eyes_size_slider:
		eyes_size_slider.value_changed.connect(func(value: int): character_data.eyes_size.value = settings.eyes_size_equivalence[value])
	
	if eyes_separation_slider:
		eyes_separation_slider.value_changed.connect(func(value: int): character_data.eyes_separation.value = settings.eyes_separation_equivalence[value])
	
	if eyes_rotation_slider:
		eyes_rotation_slider.value_changed.connect(func(value: int): character_data.eyes_rotation.value = settings.eyes_rotation_equivalence[value])
	
	if eyes_height_slider:
		eyes_height_slider.value_changed.connect(func(value: int): character_data.eyes_height.value = settings.eyes_height_equivalence[value])
	
	if skin_color_picker:
		skin_color_picker.color_changed.connect(func(value: Color): character_data.skin_color.value = value)


func initialize_value_slider(slider: Slider, steps_setting: int):
	slider.max_value = steps_setting - 1
	slider.value = int(steps_setting / 2.0)


func initialize_item_list(item_list: ItemList, values: Array):
	pass
