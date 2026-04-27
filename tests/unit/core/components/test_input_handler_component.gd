extends GutTest

var input_handler: InputHandlerComponent

func before_each():
	input_handler = InputHandlerComponent.new()
	add_child(input_handler)

func after_each():
	input_handler.free()

func test_initialization():
	assert_false(input_handler.is_active, "Should be inactive by default")
	
	input_handler.initialize_configuration()
	assert_false(input_handler._input_configuration.is_empty(), "Configuration should be populated after initialization")

func test_action_toggling():
	input_handler.set_action_enabled("movement_jump", false)
	assert_false(input_handler.is_action_enabled("movement_jump"), "Action should be disabled")
	
	input_handler.set_action_enabled("movement_jump", true)
	assert_true(input_handler.is_action_enabled("movement_jump"), "Action should be enabled")

func test_consume_mouse_delta():
	input_handler._mouse_delta_accumulated = Vector2(100, 50)
	var delta = input_handler.consume_mouse_delta()
	
	assert_eq(delta, Vector2(100, 50), "Should return the accumulated delta")
	assert_eq(input_handler._mouse_delta_accumulated, Vector2.ZERO, "Delta should be reset after consuming")

func test_unhandled_input_signal_emission():
	input_handler.is_active = true
	# Inject a fake property just for the test
	input_handler._input_configuration["movement_crouch"] = true
	
	# Watch signal
	watch_signals(input_handler)
	
	var event = InputEventAction.new()
	event.action = "movement_crouch"
	event.pressed = true
	
	input_handler._unhandled_input(event)
	assert_signal_emitted(input_handler, "crouch_started_pressed", "Should emit signal when action is pressed")
	
	event.pressed = false
	input_handler._unhandled_input(event)
	assert_signal_emitted(input_handler, "crouch_released", "Should emit signal when action is released")
