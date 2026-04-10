class_name HudReactive
extends Reactive

var state: ReactiveInt = ReactiveInt.new(0, self)

func _init():
	super._init()
