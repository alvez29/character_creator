## This node is separated from the 3D node to be rendered in the base desired resolution and not subviewport 3d scale override
extends Control

@export
var player: Player

@export
var in_sight_checker_component: InSightCheckerComponent
@export
var grabbing_behavior_component: GrabbingBehaviorComponent

@onready
var aimer: Aimer = %Aimer

@onready
var debug_info: DebugInfo = %DebugInfo

func _ready() -> void:
	if !in_sight_checker_component:
		push_warning("No grabbing behavior component attached")
	
	debug_info._player_ref = player
	in_sight_checker_component.on_grababble_in_sight.connect(aimer.on_grababble_in_sight)
	in_sight_checker_component.on_none_interactable_in_sight.connect(aimer.on_none_interactable_in_sight)
	grabbing_behavior_component.has_grabbed_something.connect(aimer.change_state.bind(Aimer.State.GRABBING))
	grabbing_behavior_component.has_released_something.connect(aimer.on_stopped_grabbing.bind(in_sight_checker_component))
