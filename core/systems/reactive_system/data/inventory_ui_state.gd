## Concrete reactive UI state model representing the player's inventory slot selection and inputs.
class_name InventoryUIState
extends Reactive

var selected_slot_index := ReactiveInt.new(0, self)
var slots_number := ReactiveInt.new(5, self)

func _init():
	super._init()

func process_inventory_slots_inputs():
	if Input.is_action_just_pressed("ui_next_inventory_slot"):
		selected_slot_index.value = ((selected_slot_index.value + 1) % slots_number.value + slots_number.value) % slots_number.value
	
	if Input.is_action_just_pressed("ui_previous_inventory_slot"):
		selected_slot_index.value = ((selected_slot_index.value - 1) % slots_number.value + slots_number.value) % slots_number.value
	
	_check_specific_inventory_slot_signal_action("ui_first_inventory_slot", 0)
	_check_specific_inventory_slot_signal_action("ui_second_inventory_slot", 1)
	_check_specific_inventory_slot_signal_action("ui_third_inventory_slot", 2)
	_check_specific_inventory_slot_signal_action("ui_fourth_inventory_slot", 3)
	_check_specific_inventory_slot_signal_action("ui_fifth_inventory_slot", 4)


func _check_specific_inventory_slot_signal_action(action_name: String, index: int):
	if Input.is_action_just_pressed(action_name):
		selected_slot_index.value = index
