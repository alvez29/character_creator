## Resource that maps an origin state to a target state, driven by a callable boolean condition that decides when to transition.
class_name StateMachineTransition
extends Resource

var origin_state: StateMachineState
var target_state: StateMachineState
var condition: Callable

func _init(_origin: StateMachineState, _target_state: StateMachineState, _new_condition: Callable = func(): return false) -> void:
	self.condition = _new_condition
	self.origin_state = _origin
	self.target_state = _target_state


func check_condition() -> bool:
	return condition and condition.call()
