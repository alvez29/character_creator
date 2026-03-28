class_name Aimer
extends Panel

enum State {
	DEFAULT,
	GRABBABLE_IN_SIGHT,
	GRABBING
}

@onready
var animation_player: AnimationPlayer = %AimerAnimationPlayer

var _old_state: State
var _actual_state := State.DEFAULT

func _ready() -> void:
	if !animation_player:
		push_warning("No animation player in Aimer... Finding in tree...")
		animation_player = Utils.get_child_of_type_recursive(self, AnimationPlayer)

func on_none_interactable_in_sight():
	if _actual_state != State.GRABBING:
		change_state(State.DEFAULT)

func on_grababble_in_sight(_object):
	if _actual_state != State.GRABBING:
		change_state(State.GRABBABLE_IN_SIGHT)

func on_stopped_grabbing(in_sigh_checker_component: InSightCheckerComponent):
	if in_sigh_checker_component.has_grabbable_in_sight():
		change_state(State.GRABBABLE_IN_SIGHT)
	else:
		change_state(State.DEFAULT)

func change_state(new_state: State):
	if _actual_state != new_state:
		_old_state = _actual_state
		_actual_state = new_state
		on_state_transition()

func on_state_transition():
	var old_state_name: String = State.keys()[_old_state]
	var new_state_name: String = State.keys()[_actual_state]
	var animation_name = old_state_name.to_lower() + "__" + new_state_name.to_lower()
	
	animation_player.play(animation_name)
