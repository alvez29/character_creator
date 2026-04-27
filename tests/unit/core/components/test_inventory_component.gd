extends GutTest

var inventory: InventoryComponent

func before_each():
	inventory = InventoryComponent.new()
	inventory.max_slots = 5
	# We need to add it to the tree so _ready runs and UIState is accessible
	add_child(inventory)

func after_each():
	for slot in inventory.slots:
		if is_instance_valid(slot):
			slot.free()
	inventory.free()

func create_test_item(stack: int = 1) -> ItemData:
	var item = ItemData.new()
	item.id = &"test_item"
	item.name = "Test Item"
	item.max_stack = stack
	return item

func test_initializes_with_max_slots():
	assert_eq(inventory.slots.size(), 5, "Should have 5 slots on init")
	for slot in inventory.slots:
		assert_not_null(slot, "Slot should be instantiated")
		assert_null(slot.item_data, "Slot should be empty by default")
		assert_eq(slot.amount, 0, "Slot amount should be 0")

func test_add_item_to_empty_slot():
	var item = create_test_item()
	var success = inventory.add_item(item, 1)
	
	assert_true(success, "Item should have been added successfully")
	assert_not_null(inventory.slots[0].item_data, "First slot should have the item")
	assert_eq(inventory.slots[0].item_data, item, "Item should match the one added")
	assert_eq(inventory.slots[0].amount, 1, "Amount should be 1")

func test_add_item_stacking():
	var item = create_test_item(10)
	inventory.add_item(item, 5)
	
	var success = inventory.add_item(item, 3)
	assert_true(success, "Second stack addition should be successful")
	
	assert_eq(inventory.slots[0].amount, 8, "Slot should contain 8 stacked items")
	assert_null(inventory.slots[1].item_data, "Second slot should still be empty")

func test_add_item_overflow_to_next_slot():
	var item = create_test_item(10)
	inventory.add_item(item, 8)
	
	var success = inventory.add_item(item, 5) # 2 go into first slot, 3 overflow to next
	assert_true(success, "Overflow addition should be successful")
	
	assert_eq(inventory.slots[0].amount, 10, "First slot should be full")
	assert_eq(inventory.slots[1].amount, 3, "Second slot should have overflow amount")
	assert_eq(inventory.slots[1].item_data, item, "Second slot should have same item")

func test_add_item_when_inventory_full():
	var item = create_test_item(1)
	for i in range(5):
		inventory.add_item(item, 1)
	
	var success = inventory.add_item(item, 1)
	assert_false(success, "Should fail to add item when inventory is full and max stack reached")

func test_change_active_slot_within_bounds():
	inventory.change_active_slot(2)
	assert_eq(inventory.active_slot_index, 2, "Active slot should be updated to 2")

func test_change_active_slot_out_of_bounds_is_ignored():
	inventory.change_active_slot(2)
	inventory.change_active_slot(10)
	assert_eq(inventory.active_slot_index, 2, "Active slot should remain unchanged when exceeding max")
	
	inventory.change_active_slot(-1)
	assert_eq(inventory.active_slot_index, 2, "Active slot should remain unchanged when negative")

func test_get_active_item_data():
	var item = create_test_item()
	inventory.add_item(item, 1) # Will go to slot 0
	
	inventory.change_active_slot(0)
	var active_item = inventory.get_active_item_data()
	assert_eq(active_item, item, "Should return the correct active item data")
	
	inventory.change_active_slot(1)
	assert_null(inventory.get_active_item_data(), "Should return null if active slot is empty")
