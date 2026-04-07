extends Label

var _player_ref: Player

func _ready() -> void:
	# Since this is a debug thing I don't care about this workaround
	_player_ref = get_parent().get_parent() as Player

func _process(_delta: float) -> void:
	var building_text = ""
	
	building_text += "FPS " + str(int(Engine.get_frames_per_second())) + " \n"
	
	if _player_ref:
		building_text += "Player Speed \n"
		building_text += "    | " + str(snappedf(_player_ref.velocity.length(), 0.01)) + " m/s \n"
		building_text += "    | " + str(snappedf(Utils.ms_to_kmh(_player_ref.velocity.length()), 0.01)) + " km/h \n"
		
		building_text += "State \n"
		
		if _player_ref.movement_component._is_crouched:
			building_text += "    | Crouching \n"
		
		if _player_ref.movement_component._is_sliding:
			building_text += "    | Sliding \n"
		
		building_text += "Possesed: " + str(PlayerController.possessed_pawn)
	
	text = building_text
