## Component that periodically casts a ray forward to detect interactable objects.
## Emits signals when a GrabbableComponent comes into or leaves the player's line of sight.
class_name InSightCheckerComponent
extends Node3D

signal on_grababble_in_sight(object)
signal on_none_interactable_in_sight



@onready var timer = %CheckerTimer

@export var subject: CharacterBody3D
@export var interact_distance: float = 7
@export var check_time: float = 0.1
@export_flags_2d_physics var collision_mask: int = 4

var last_grababble_id: int = -1


func _ready() -> void:
	timer.wait_time = check_time
	timer.start()

func check_in_front():
	var camera := get_viewport().get_camera_3d()
	if not camera: return
	
	var origin := camera.global_position
	var direction := -camera.global_transform.basis.z
	var target := origin + (direction * interact_distance)

	var result = Utils.Physics.intersect_ray(get_world_3d(), origin, target, 0xFFFFFFFF, [subject.get_rid()])
	
	if result and result.collider:
		var collider = result.collider
		var collider_id = result.rid.get_id()
		var is_grabbable = collider.has_meta(GrabbableComponent.grabbable_meta_key)
		
		if is_grabbable:
			last_grababble_id = collider_id
			on_grababble_in_sight.emit(collider)
		else:
			_clear_sight()
	else:
		_clear_sight()


func _clear_sight():
	last_grababble_id = -1
	on_none_interactable_in_sight.emit()


func has_grabbable_in_sight() -> bool:
	return last_grababble_id != -1


func _on_timer_timeout() -> void:
	check_in_front()
