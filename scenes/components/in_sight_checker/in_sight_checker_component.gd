class_name InSightCheckerComponent
extends Node3D

signal on_grababble_in_sight(object)
signal on_none_interactable_in_sight

@export var interact_distance: float = 7
@export_flags_3d_physics  var collision_mask: int

var last_grababble_id: int = -1

func _process(_delta: float) -> void:
	var origin = get_viewport().get_camera_3d().global_position
	var target = origin + (-get_viewport().get_camera_3d().global_transform.basis.z * interact_distance)
	var hit = Utils._cast_ray(get_world_3d(), origin, target, collision_mask)
	
	if hit and hit.collider is Grabbable and hit.collider is RigidBody3D:
		if last_grababble_id != hit.collider_id or last_grababble_id == -1:
			last_grababble_id = hit.collider_id
			on_grababble_in_sight.emit(hit.collider)
	
	if not hit:
		last_grababble_id = -1
		on_none_interactable_in_sight.emit()


func has_grabbable_in_sight() -> bool:
	return last_grababble_id != -1
