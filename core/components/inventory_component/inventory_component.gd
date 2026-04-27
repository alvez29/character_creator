class_name InventoryComponent
extends Node

signal slot_changed(index: int)
signal active_slot_changed(new_index: int)




@export_category("Components")
@export var input_handler: InputHandlerComponent

@export_category("Settings")
@export var max_slots: int = 5
@export var slots: Array[InventorySlotData] = []

var active_slot_index: int = 0


func _ready() -> void:
	if slots.is_empty():
		for i in range(max_slots):
			slots.append(InventorySlotData.new())
			
	UIState.inventory_ui_state.slots_number.value = max_slots
	UIState.inventory_ui_state.slots.assign(slots.duplicate())
	
	slot_changed.connect(_on_slot_changed)
	
	if input_handler:
		input_handler.next_inventory_slot.connect(_on_input_handler_next_inventory_slot)
		input_handler.previous_inventory_slot.connect(_on_input_handler_previous_inventory_slot)
		input_handler.select_inventory_slot.connect(func(new_index): change_active_slot(new_index))



func _on_input_handler_next_inventory_slot():
	change_active_slot(((active_slot_index + 1) % max_slots + max_slots) % max_slots)


func _on_input_handler_previous_inventory_slot():
	change_active_slot(((active_slot_index - 1) % max_slots + max_slots) % max_slots)


func _on_slot_changed(index: int) -> void:
	UIState.inventory_ui_state.slots.set_at(index, slots[index])


func add_item(item: ItemData, amount: int = 1) -> bool:
	for i in range(slots.size()):
		if slots[i].item_data == item and slots[i].amount < item.max_stack:
			var space_left = item.max_stack - slots[i].amount
			
			if amount <= space_left:
				slots[i].amount += amount
				slot_changed.emit(i)
				return true
			else:
				slots[i].amount += space_left
				amount -= space_left
				slot_changed.emit(i)

	for i in range(slots.size()):
		if slots[i].item_data == null:
			slots[i].item_data = item
			slots[i].amount = amount
			slot_changed.emit(i)
			return true
			
	return false


func change_active_slot(new_index: int) -> void:
	if new_index == active_slot_index or new_index < 0 or new_index >= max_slots:
		return
		
	active_slot_index = new_index
	active_slot_changed.emit(active_slot_index)
	UIState.inventory_ui_state.selected_slot_index.value = active_slot_index


func get_active_item_data() -> ItemData:
	if active_slot_index >= 0 and active_slot_index < slots.size():
		var slot = slots[active_slot_index]
		if slot != null:
			return slot.item_data
	return null
