extends GutTest

var pawn: PawnComponent
var input_handler: InputHandlerComponent
var camera: Camera3D

func before_each():
	input_handler = InputHandlerComponent.new()
	add_child(input_handler)
	
	camera = Camera3D.new()
	add_child(camera)
	
	pawn = PawnComponent.new()
	pawn.input_handler_component = input_handler
	pawn.camera = camera
	add_child(pawn)

func after_each():
	pawn.free()
	camera.free()
	input_handler.free()

func test_possess():
	assert_false(pawn.is_possessed)
	assert_false(input_handler.is_active)
	

	watch_signals(pawn)
	pawn.possess()
	
	assert_true(pawn.is_possessed)
	assert_true(input_handler.is_active)
	assert_true(camera.current)
	assert_signal_emitted(pawn, "on_possessed")

func test_unpossess():
	pawn.possess()
	
	watch_signals(pawn)
	pawn.unpossess()
	
	assert_false(pawn.is_possessed)
	assert_false(input_handler.is_active)
	assert_false(camera.current)
	assert_signal_emitted(pawn, "on_unpossessed")
