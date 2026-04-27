extends GutTest

var day_cycle: DayNightCycleComponent

func before_each():
	day_cycle = DayNightCycleComponent.new()
	add_child(day_cycle)

func after_each():
	day_cycle.free()

func test_initialization():
	assert_null(day_cycle.sun_light, "Sun light should be null by default")
	
	var light = DirectionalLight3D.new()
	day_cycle.sun_light = light
	assert_not_null(day_cycle.sun_light, "Sun light should be assignable")
	light.free()
