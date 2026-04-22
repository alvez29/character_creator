## A global manager that handles debug actions and utility keys such as changing maximum FPS and alternating pawn possession.
extends Node
@export
var vehicle: Node3D

@export var player: Player

var is_camera_in_player

@export var max_fps_options: Array[int] = [10, 20, 30, 60, 120, 200]

var _selected_max_fps_option: int = 4

func _ready() -> void:
	player.pawn_component.possess()
	Engine.max_fps = max_fps_options[_selected_max_fps_option]


func _input(event):
	if event is InputEventKey:
		if event.pressed and not event.echo:
			if event.keycode == KEY_P and Input.is_key_pressed(KEY_CTRL):
				_selected_max_fps_option = (_selected_max_fps_option + 1) % max_fps_options.size()
				Engine.max_fps = max_fps_options[_selected_max_fps_option]
				return
				
			
			if event.keycode == KEY_P:
				is_camera_in_player = not is_camera_in_player
		
			if is_camera_in_player:
				PlayerController.possess(vehicle)
			else:
				PlayerController.possess(player)
