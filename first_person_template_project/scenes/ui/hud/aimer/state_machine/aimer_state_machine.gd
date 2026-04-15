## State machine dictating specific behaviors and transitions for the player's crosshair element based on environment interactions.
class_name AimerStateMachine
extends StateMachineComponent

@export
var in_sight_checker_component: InSightCheckerComponent
@export
var grabbing_behavior_component: GrabbingBehaviorComponent

var default_state := StateMachineState.new("default")
var in_sight_state := StateMachineState.new("grabbable_in_sight")
var grabbing_state := StateMachineState.new("grabbing")

var default_in_sight := StateMachineTransition.new(default_state, in_sight_state, func(): return in_sight_checker_component.has_grabbable_in_sight())
var in_sight_default := StateMachineTransition.new(in_sight_state, default_state, func(): return not in_sight_checker_component.has_grabbable_in_sight())
var in_sight_grabbing := StateMachineTransition.new(in_sight_state, grabbing_state, func(): return grabbing_behavior_component.is_grabbing)
var grabbing_default := StateMachineTransition.new(grabbing_state, default_state, func(): return not grabbing_behavior_component.is_grabbing and not in_sight_checker_component.has_grabbable_in_sight())
var grabbing_in_sight := StateMachineTransition.new(grabbing_state, in_sight_state, func(): return not grabbing_behavior_component.is_grabbing and in_sight_checker_component.has_grabbable_in_sight())

func get_actual_state() -> StateMachineState:
	return default_state

func get_transitions() -> Array[StateMachineTransition]:
	return [
		default_in_sight,
		in_sight_default,
		in_sight_grabbing,
		grabbing_default,
		grabbing_in_sight,
	]
