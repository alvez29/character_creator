extends Node

var inventory_ui_state: InventoryUIState = InventoryUIState.new()

func _process(delta: float) -> void:
	inventory_ui_state.process_inventory_slots_inputs()
