extends GutTest

var camera_manager: FirstPersonCameraManager
var camera: Camera3D

func before_each():
	camera = Camera3D.new()
	add_child(camera)
	
	camera_manager = FirstPersonCameraManager.new()
	camera_manager.camera = camera
	add_child(camera_manager)

func after_each():
	camera_manager.free()
	camera.free()

func test_tilt_logic():
	camera_manager.should_tilt = true
	camera_manager.tilt_angle = 10.0
	camera_manager.tilt(1.0, 0.1) # Simulate moving right
	
	assert_eq(camera_manager._target_tilt, deg_to_rad(-10.0), "Target tilt should be set correctly for right movement")
	
	camera_manager.tilt(-1.0, 0.1) # Simulate moving left
	assert_eq(camera_manager._target_tilt, deg_to_rad(10.0), "Target tilt should be set correctly for left movement")

func test_fov_dynamic_adjustment():
	camera_manager.should_change_fov_by_speed = true
	camera_manager.base_fov = 75.0
	camera_manager.action_max_fov = 90.0
	camera_manager.fov_max_speed_reference = 10.0
	camera.fov = 75.0
	
	# Simulate high speed action
	camera_manager.adjust_dynamic_fov(0.5, 10.0, true)
	assert_true(camera.fov > 75.0, "FOV should increase when moving fast in action state")
	
	# Simulate standing still
	camera_manager.adjust_dynamic_fov(0.5, 0.0, false)
	assert_true(camera.fov < 90.0, "FOV should decrease towards base when not in action mode or slow")

func test_active_camera():
	camera_manager.active_camera()
	assert_true(camera.current, "Camera should be set as current")

func test_tilt_processing():
	camera_manager._current_tilt = 0.0
	camera_manager._target_tilt = 1.0 # arbitrary rad
	camera_manager.tilt_speed = 10.0
	
	camera_manager._try_process_tilt(0.1)
	assert_true(camera_manager._current_tilt > 0.0, "Current tilt should interpolate towards target tilt")
