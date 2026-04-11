extends HBoxContainer


var _inventory_bar_slot_scene = preload("res://scenes/ui/inventory_bar/inventory_bar_slot.tscn")

func _ready() -> void:
	for i in range(UIState.inventory_ui_state.slots_number.value):
		var slot_data = InventoryBarSlotData.new(i, null)
		spawn_slot(slot_data)


func spawn_slot(slot_data):
	var slot_instance := _inventory_bar_slot_scene.instantiate() as InventoryBarSlot
	
	slot_instance.initialize_data(slot_data)
	UIState.inventory_ui_state.selected_slot_index.reactive_changed.connect(slot_instance._on_any_slot_selected)
	add_child(slot_instance)
