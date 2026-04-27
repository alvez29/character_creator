class_name ReactiveTexture
extends Reactive


func _init(initial_value : Texture2D = null, initial_owner : Reactive = null) -> void:
	super._init(initial_owner)
	value = initial_value

var value : Texture2D:
	set(v):
		value = v
		reactive_changed.emit(self)
		return value
