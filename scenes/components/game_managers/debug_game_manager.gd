extends Node

@export
var vehicle: Vehicle

@export
var player: Player

var is_camera_in_player

func _ready() -> void:
	player.pawn_component.possess()

func _input(event):
	if event is InputEventKey:
		if event.pressed and not event.echo:
			if event.keycode == KEY_P:
				is_camera_in_player = not is_camera_in_player
		
			if is_camera_in_player:
				PlayerController.possess(vehicle)
			else:
				PlayerController.possess(player)
