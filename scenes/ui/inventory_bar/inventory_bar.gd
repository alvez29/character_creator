extends HBoxContainer

signal on_slot_selected(selected_slot_index: int)

var _inventory_bar_slot_scene = preload("res://scenes/ui/inventory_bar/inventory_bar_slot.tscn")

@export
var slots_number: int = 5

var _selected_slot: int = 0

func _ready() -> void:
	for i in range(slots_number):
		var slot_data = InventoryBarSlotData.new(i, null)
		spawn_slot(slot_data)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_next_inventory_slot"):
		_selected_slot  = ((_selected_slot + 1) % slots_number + slots_number) % slots_number
		on_slot_selected.emit(_selected_slot)
	
	if Input.is_action_just_pressed("ui_previous_inventory_slot"):
		_selected_slot  = ((_selected_slot - 1) % slots_number + slots_number) % slots_number
		on_slot_selected.emit(_selected_slot)
	
	_check_specific_inventory_slot_signal_action("ui_first_inventory_slot", 0)
	_check_specific_inventory_slot_signal_action("ui_second_inventory_slot", 1)
	_check_specific_inventory_slot_signal_action("ui_third_inventory_slot", 2)
	_check_specific_inventory_slot_signal_action("ui_fourth_inventory_slot", 3)
	_check_specific_inventory_slot_signal_action("ui_fifth_inventory_slot", 4)


func spawn_slot(slot_data):
	var slot_instance := _inventory_bar_slot_scene.instantiate() as InventoryBarSlot
	
	slot_instance.initialize_data(slot_data)
	on_slot_selected.connect(slot_instance._on_any_slot_selected)
	add_child(slot_instance)


func _check_specific_inventory_slot_signal_action(action_name: String, index: int):
	if Input.is_action_just_pressed(action_name):
		_selected_slot  = index
		on_slot_selected.emit(index)
