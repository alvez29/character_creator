class_name InSightCheckerComponent
extends Node3D

signal on_grababble_in_sight(object)
signal on_none_interactable_in_sight

@onready var raycast = %InSightRaycast
@onready var timer = %CheckerTimer

@export var interact_distance: float = 7
@export var check_time: float = 0.1

var last_grababble_id: int = -1

func _ready() -> void:
	raycast.target_position = Vector3.FORWARD * interact_distance
	timer.wait_time = check_time
	timer.start()

func check_in_front():
	var collider = raycast.get_collider()
	var collider_id = raycast.get_collider_rid().get_id()
	
	if raycast.is_colliding() and collider:
		if collider is Grabbable:
			last_grababble_id = collider_id
			on_grababble_in_sight.emit(collider)
	else:
		last_grababble_id = -1
		on_none_interactable_in_sight.emit()


func has_grabbable_in_sight() -> bool:
	return last_grababble_id != -1


func _on_timer_timeout() -> void:
	check_in_front()
