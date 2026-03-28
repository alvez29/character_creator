class_name InventoryBarSlotData
extends Node

var index: int
var texture: Texture2D

func _init(index: int, texture: Texture2D) -> void:
	self.index = index
	self.texture = texture
