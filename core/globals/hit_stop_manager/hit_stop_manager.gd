extends Node

func frame_freeze(duration, time_scale := 0.05):
	Engine.time_scale = time_scale
	await get_tree().create_timer(duration * time_scale).timeout
	Engine.time_scale = 1.0
