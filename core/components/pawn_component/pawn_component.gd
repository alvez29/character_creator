## Component that allows a Node to be possessed and controlled by a player controller, enabling input and camera capture.
class_name PawnComponent
extends Node

@export var input_handler_component: InputHandlerComponent
@export var camera: Camera3D

signal on_possessed
signal on_unpossessed

var is_possessed: bool = false

func _ready() -> void:
	if not input_handler_component:
		push_error("[PawnComponent] A pawn that is possesable should have an InputHandlerComponent")


func possess() -> void:
	if is_possessed: return
	is_possessed = true
	input_handler_component.is_active = true
	if camera: camera.current = true
	on_possessed.emit()


func unpossess() -> void:
	if not is_possessed: return
	is_possessed = false
	input_handler_component.is_active = false
	if camera: camera.current = false
	on_unpossessed.emit()
