## Reactive Color variable that triggers change signals whenever its inner value is updated.
class_name ReactiveColor
extends Reactive

func _init(initial_value : Color = Color.WHITE, initial_owner : Reactive = null) -> void:
	super._init(initial_owner)
	value = initial_value

var value : Color:
	set(v):
		value = v
		reactive_changed.emit(self)
		return value
