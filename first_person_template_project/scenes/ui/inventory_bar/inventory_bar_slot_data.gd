class_name InventoryBarSlotData
extends Node

var index: int
var texture: Texture2D

func _init(new_index: int, new_texture: Texture2D) -> void:
	self.index = new_index
	self.texture = new_texture
