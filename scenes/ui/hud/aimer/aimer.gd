class_name Aimer
extends Panel


@onready
var animation_player: AnimationPlayer = %AimerAnimationPlayer
@onready
var state_machine: StateMachineComponent = %AimerStateMachine

func _ready() -> void:
	state_machine.on_state_changed.connect(on_state_transition)

func on_state_transition(_actual_state: StateMachineState, source_transition: StateMachineTransition):
	var old_state: StateMachineState = source_transition.origin_state
	var new_state: StateMachineState = source_transition.target_state
	
	var animation_name = old_state.name + "__" + new_state.name
	
	animation_player.play(animation_name)
