extends Control

@export
var grabbing_behavior_component: GrabbingBehaviorComponent

@onready
var aimer: Aimer = %Aimer

func _ready() -> void:
	if !grabbing_behavior_component:
		push_warning("No grabbing behavior component attached")
	
	grabbing_behavior_component.has_grabbed_something.connect(aimer.change_state.bind(Aimer.State.GRABBING))
	grabbing_behavior_component.has_released_something.connect(aimer.change_state.bind(Aimer.State.DEFAULT))
