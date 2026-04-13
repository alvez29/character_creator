class_name InventoryBarSlot
extends Panel

var data: InventoryBarSlotData
var is_selected: bool = false

@onready
var _index_label = %IndexLabel

@onready
var animation_player: AnimationPlayer = %SlotAnimationPlayer

var selected_slot_material = preload("uid://bhlugul5ya3ln")
var unselected_slot_material = preload("uid://c8spojoco01vj")

func initialize_data(new_data: InventoryBarSlotData):
	self.data = new_data
	self.is_selected = new_data.index == 0


func _ready() -> void:
	_bind_data()

func _bind_data():
	var panel_style = selected_slot_material if is_selected else unselected_slot_material
	_index_label.text = str(data.index + 1)
	add_theme_stylebox_override("panel", panel_style)


func _on_any_slot_selected(selected_slot: ReactiveInt):
	var self_is_selected = selected_slot.value == data.index
	
	is_selected = self_is_selected
	
	if self_is_selected:
		animation_player.stop()
		animation_player.play("selected")
	
	_bind_data()
