class_name RangeWidget
extends Widget

@onready var label: Label = %Label
@onready var slider: Slider = %Slider

func load_setting(setting: CharacterSetting, data: Reactive):
	var range_setting = setting as RangeSetting
	
	if slider:
		slider.value_changed.connect(
			func(step: int): data.value = setting.get_value(step))
		
		slider.max_value = range_setting.steps - 1
		slider.value = int(range_setting.steps / 2.0)
	
	if label:
		label.text = setting.display_name
