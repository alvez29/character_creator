extends GutTest

var movement: FirstPersonMovementComponent
var body: CharacterBody3D

func before_each():
	body = CharacterBody3D.new()
	movement = FirstPersonMovementComponent.new()
	movement.body = body
	body.add_child(movement)
	add_child(body)

func after_each():
	body.free()

func test_initial_state():
	assert_false(movement.is_crouched, "Should not be crouched initially")
	assert_false(movement.is_sprinting, "Should not be sprinting initially")
	assert_false(movement.is_sliding, "Should not be sliding initially")

func test_crouch_logic():
	assert_false(movement.is_crouched)
	movement.crouch()
	assert_true(movement._crouch_queued, "Crouch should be queued if not on floor")

func test_sprint_state_toggle():
	movement.set_sprinting(true)
	assert_true(movement.is_sprinting, "Sprint state should be enabled")
	
	movement.set_sprinting(false)
	assert_false(movement.is_sprinting, "Sprint state should be disabled")

func test_cancel_wall_run():
	movement.is_wall_running = true
	movement.cancel_wall_run()
	assert_false(movement.is_wall_running, "Wall running should be cancelled")

func test_add_force_and_impulse():
	var initial_force = movement._accumulated_force
	movement.add_force(Vector3(10, 0, 0))
	assert_eq(movement._accumulated_force, initial_force + Vector3(10, 0, 0), "Force should be accumulated")
	
	var initial_vel = body.velocity
	movement.mass = 2.0
	movement.add_impulse(Vector3(10, 0, 0))
	assert_eq(body.velocity, initial_vel + Vector3(5, 0, 0), "Impulse should immediately modify velocity accounting for mass")
