class_name ReactiveMesh
extends Reactive

func _init(initial_value : Mesh, initial_owner : Reactive = null) -> void:
	super._init(initial_owner)
	value = initial_value

var value : Mesh:
	set(v):
		value = v
		reactive_changed.emit(self)
		return value
