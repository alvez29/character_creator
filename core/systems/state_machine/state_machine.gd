## Abstract component to build discrete state machines that transition between distinct states based on provided conditions.
@abstract
class_name StateMachineComponent
extends Node

signal on_state_changed(new_state: StateMachineState, source_transition: StateMachineTransition)

var actual_state: StateMachineState
var transitions: Array[StateMachineTransition] = []

var _transitions_by_origin: Dictionary[StateMachineState, Array] = {}
var _transition_to_check: Array = []

func _ready() -> void:
	initialize_states()
	_build_transition_index()
	_setup_current_state_transitions()


func initialize_states():
	actual_state = get_actual_state()
	transitions = get_transitions()


func _build_transition_index():
	for transition in transitions:
		if not _transitions_by_origin.has(transition.origin_state):
			_transitions_by_origin[transition.origin_state] = []
		_transitions_by_origin[transition.origin_state].append(transition)


func _setup_current_state_transitions():
	if not actual_state:
		return
	
	_transition_to_check = _transitions_by_origin.get(actual_state, [])


@abstract
func get_actual_state() -> StateMachineState


@abstract
func get_transitions() -> Array[StateMachineTransition]
 

func _process(_delta: float) -> void:
	for transition in _transition_to_check:
		if transition.check_condition():
			change_state(transition)
			break


func change_state(source_transition: StateMachineTransition = null):
	actual_state = source_transition.target_state
	
	_setup_current_state_transitions()
	
	on_state_changed.emit(actual_state, source_transition)
