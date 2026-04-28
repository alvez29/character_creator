## A selectable color option with a stable string ID.
## Save each option as its own .tres file and add it to a ColorSelectSetting.
class_name ColorOption
extends SelectOption

@export var color: Color = Color.WHITE
