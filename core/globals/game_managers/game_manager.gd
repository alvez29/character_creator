@abstract
class_name GameManager
extends Node

@export
var hud: Control

func load_hud_reference(hud_node: Control):
	self.hud = hud_node
