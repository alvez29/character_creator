@abstract
class_name MetaComponent
extends Node

@export
var target_body: Node

@abstract
func get_related_meta() -> StringName

func _ready():
	if target_body:
		target_body.set_meta(get_related_meta(), self)
	else:
		push_error("[MetaComponent] This component should have a target body!")

func _exit_tree():
	if target_body and target_body.has_meta(get_related_meta()):
		target_body.remove_meta(get_related_meta())
