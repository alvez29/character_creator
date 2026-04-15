## Resource representing a standalone conceptual state in a State Machine context.
class_name StateMachineState
extends Resource

@export
var name = ""

func _init(_name: String) -> void:
	self.name = _name
