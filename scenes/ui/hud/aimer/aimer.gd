class_name Aimer
extends Panel

enum State {
	DEFAULT,
	GRABBING
}

var _actual_state := State.DEFAULT

@export
var animation_player: AnimationPlayer

func _ready() -> void:
	if !animation_player:
		push_warning("No animation player in Aimer... Finding in tree...")
		animation_player = Utils.get_child_of_type_recursive(self, AnimationPlayer)


func change_state(new_state: State):
	if _actual_state != new_state:
		on_state_transition(_actual_state, new_state)
		_actual_state = new_state


func on_state_transition(old_state, new_state):
	match old_state:
		State.DEFAULT:
			if new_state == State.GRABBING:
				animation_player.play("default_grabbing")
		State.GRABBING:
			if new_state == State.DEFAULT:
				animation_player.play("grabbing_default")
