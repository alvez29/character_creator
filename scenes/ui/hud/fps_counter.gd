class_name DebugInfo
extends Label


var _player_ref: Player

@export
var camera: Camera3D

func _process(_delta: float) -> void:
	
	var building_text = ""
	
	building_text += "FPS " + str(int(Engine.get_frames_per_second())) + " \n"
	
	if _player_ref:
		var speed_ms = snappedf(_player_ref.velocity.length(), 0.01)
		var speed_kmh = snappedf(Utils.ms_to_kmh(_player_ref.velocity.length()), 0.01)
		
		building_text += "Player Speed \n"
		building_text += "    | %0.1f m/s\n" % speed_ms
		building_text += "    | %0.1f km/h\n" % speed_kmh
		
		building_text += "State \n"
		
		if _player_ref.movement_component._is_crouched:
			building_text += "    | Crouching \n"
		
		if _player_ref.movement_component._is_sliding:
			building_text += "    | Sliding \n"
		
		if camera:
			building_text += "    | FOV %f \n" % camera.fov

		
		building_text += "Possesed: " + str(PlayerController.possessed_pawn)
	
	text = building_text

	
