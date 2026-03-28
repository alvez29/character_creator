extends Control

@export
var in_sight_checker_component: InSightCheckerComponent
@export
var grabbing_behavior_component: GrabbingBehaviorComponent

@onready
var aimer: Aimer = %Aimer

func _ready() -> void:
	if !in_sight_checker_component:
		push_warning("No grabbing behavior component attached")
	
	in_sight_checker_component.on_grababble_in_sight.connect(aimer.on_grababble_in_sight)
	in_sight_checker_component.on_none_interactable_in_sight.connect(aimer.on_none_interactable_in_sight)
	grabbing_behavior_component.has_grabbed_something.connect(aimer.change_state.bind(Aimer.State.GRABBING))
	grabbing_behavior_component.has_released_something.connect(aimer.on_stopped_grabbing.bind(in_sight_checker_component))
