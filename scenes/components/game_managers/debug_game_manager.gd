extends Node

@export
var vehicle: Vehicle

@export
var player: Player

var is_camera_in_player

func _input(event):
	if event is InputEventKey:
		if event.pressed and not event.echo:
			if event.keycode == KEY_P:
				is_camera_in_player = not is_camera_in_player
		
			if is_camera_in_player:
				vehicle.active_camera()
			else:
				player.camera_manager.active_camera()
