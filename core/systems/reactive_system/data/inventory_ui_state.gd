## Concrete reactive UI state model representing the player's inventory slot selection and inputs.
class_name InventoryUIState
extends Reactive

var selected_slot_index := ReactiveInt.new(0, self)
var slots_number := ReactiveInt.new(5, self)

var slots := ReactiveArray.new([])

func _init():
	super._init()
