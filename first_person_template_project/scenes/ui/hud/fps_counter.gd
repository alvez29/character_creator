## Label displaying various on-screen debugging metrics like frames per second, player physics speed, and game state.
class_name DebugInfo
extends Label

@export
var player: Player

@export
var camera: Camera3D

var building_text = ""

func _process(_delta: float) -> void:
	building_text += "FPS " + str(int(Engine.get_frames_per_second())) + " \n"
	
	if player:
		var speed_ms = snappedf(player.velocity.length(), 0.01)
		var speed_kmh = snappedf(Utils.ms_to_kmh(player.velocity.length()), 0.01)
		
		add_line("Max Jump Height: %0.2fm" % Utils.get_max_jump_height(player.movement_component.jump_velocity, 9.8 * player.movement_component.gravity_factor))
		
		add_line("Player Speed")
		add_line("    | %0.1f m/s" % speed_ms)
		add_line("    | %0.1f km/h" % speed_kmh)
		
		add_line("State")
		
		if player.movement_component._is_crouched:
			add_line("    | Crouching")
		
		if player.movement_component._is_sliding:
			add_line("    | Sliding")
		
		if camera:
			add_line("    | FOV %f" % camera.fov)

		
		add_line("Possesed: " + str(PlayerController.possessed_pawn))
	
	text = building_text
	clear_text()

func add_line(line: String):
	building_text += "%s \n" % line


func clear_text():
	building_text = ""
