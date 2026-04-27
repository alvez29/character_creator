# Represents a slot in the inventory
class_name InventorySlotData
extends Node

@export var item_data: ItemData
@export var amount: int = 0:
	set(value):
		amount = value
		if amount <= 0:
			item_data = null
			amount = 0
