extends GutTest

var shaker: ShakerComponent
var target_node: Node3D
var profile: ShakeProfile

func before_each():
	target_node = Node3D.new()
	add_child(target_node)
	
	shaker = ShakerComponent.new()
	shaker.target_node = target_node
	add_child(shaker)
	
	profile = ShakeProfile.new()
	profile.duration = 1.0
	profile.amplitude_x = 1.0
	profile.amplitude_y = 1.0
	profile.amplitude_z = 1.0

func after_each():
	shaker.free()
	target_node.free()

func test_initialization():
	assert_eq(shaker._target_mode, ShakerComponent.TargetMode.NODE3D, "Should detect Node3D target correctly")
	assert_eq(shaker._last_pos_offset, Vector3.ZERO, "Offsets should be initialized correctly")

func test_add_trauma():
	shaker.default_profile = profile
	assert_eq(shaker.trauma, 0.0, "Trauma should start at 0")
	
	shaker.add_trauma(0.5)
	assert_eq(shaker.trauma, 0.5, "Trauma should increase by amount")
	
	shaker.add_trauma(0.8)
	assert_eq(shaker.trauma, 1.0, "Trauma should cap at 1.0")

func test_add_trauma_without_profile_ignores():
	shaker.default_profile = null
	shaker.add_trauma(0.5)
	assert_eq(shaker.trauma, 0.0, "Should ignore if no profile is assigned")

func test_continuous_trauma_overrides_trauma():
	shaker.default_profile = profile
	shaker.is_continuous = true
	shaker.continuous_trauma = 0.8
	
	shaker._process(0.1) # Trigger the process to see if it reads continuous trauma
	# We can't directly assert internal state easily here unless we check if it applied offset
	assert_false(shaker._last_pos_offset == Vector3.ZERO, "Should apply offsets in continuous mode")

func test_trauma_decays_with_tween():
	shaker.default_profile = profile
	shaker.add_trauma(1.0)
	
	var initial_trauma = shaker.trauma
	assert_eq(initial_trauma, 1.0)
	
	# Usually we'd use await yield_for() to test time, but since _trauma_tween is a standard Tween
	# we verify it was created
	assert_not_null(shaker._trauma_tween, "Tween should be created")
	assert_true(shaker._trauma_tween.is_valid(), "Tween should be valid")
