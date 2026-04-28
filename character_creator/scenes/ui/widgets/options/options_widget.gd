class_name OptionsWidget
extends Widget

@onready var label: Label = %Label
@onready var item_list: ItemList = %ItemList

func load_setting(setting: CharacterSetting, data: Reactive):
	if item_list:
		item_list.clear()
			
		for option in setting.get_options():
			if option is TextureOption:
				item_list.add_item(option.display_name, option.texture)
			elif option is ColorOption:
				item_list.add_item(option.display_name, Utils.get_texture_from_color(option.color))
			elif option is MeshOption:
				item_list.add_item(option.display_name, option.preview_texture)
		
		item_list.item_selected.connect(_on_item_list_on_item_selected.bind(setting, data))
		item_list.select(0)
		_on_item_list_on_item_selected(0, setting, data)
	
	if label:
		label.text = setting.display_name


func _on_item_list_on_item_selected(index: int, setting: CharacterSetting, data: Reactive):
	var selected_option = setting.get_options()[index]
	
	if selected_option is TextureOption:
		data.value = selected_option.texture
	elif selected_option is ColorOption:
		data.value = selected_option.color
	elif selected_option is MeshOption:
		data.value = selected_option.mesh
