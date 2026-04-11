class_name DebugInfo
extends Label

@export
var player: Player

@export
var camera: Camera3D

func _process(_delta: float) -> void:
	
	var building_text = ""
	
	building_text += "FPS " + str(int(Engine.get_frames_per_second())) + " \n"
	
	if player:
		var speed_ms = snappedf(player.velocity.length(), 0.01)
		var speed_kmh = snappedf(Utils.ms_to_kmh(player.velocity.length()), 0.01)
		
		building_text += "Player Speed \n"
		building_text += "    | %0.1f m/s\n" % speed_ms
		building_text += "    | %0.1f km/h\n" % speed_kmh
		
		building_text += "State \n"
		
		if player.movement_component._is_crouched:
			building_text += "    | Crouching \n"
		
		if player.movement_component._is_sliding:
			building_text += "    | Sliding \n"
		
		if camera:
			building_text += "    | FOV %f \n" % camera.fov

		
		building_text += "Possesed: " + str(PlayerController.possessed_pawn)
	
	text = building_text

	
