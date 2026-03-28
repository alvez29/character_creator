class_name InventoryBarSlot
extends Panel

var data: InventoryBarSlotData
var is_selected: bool = false

@onready
var _index_label = %IndexLabel

@onready
var animation_player: AnimationPlayer = %SlotAnimationPlayer

var selected_slot_material = load("res://assets/inventory_bar/selected_inventory_bar_slot.tres")
var unselected_slot_material = load("res://assets/inventory_bar/unselected_inventory_bar_slot.tres")

func initialize_data(data: InventoryBarSlotData):
	self.data = data
	self.is_selected = data.index == 0


func _ready() -> void:
	_bind_data()


func _bind_data():
	var panel_style = selected_slot_material if is_selected else unselected_slot_material
	_index_label.text = str(data.index + 1)
	add_theme_stylebox_override("panel", panel_style)


func _on_any_slot_selected(selected_slot):
	var self_is_selected = selected_slot == data.index
	
	is_selected = self_is_selected
	
	if self_is_selected:
		animation_player.stop()
		animation_player.play("selected")
	
	_bind_data()
