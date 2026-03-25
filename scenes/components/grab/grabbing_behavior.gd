extends Node3D

@export
var _camera: Camera3D

@export_category("Grabbing")
@export var interact_distance: float = 3.0

var _grabbed_object: Grabbable
var _is_grabbing = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("grab"):
		if _is_grabbing:
			_stop_grabbing()
		else:
			_try_grab()
	

func _try_grab():
	if Input.is_action_pressed("grab"):
		if not _is_grabbing:
			var hit = _cast_ray()
			
			if hit and hit.collider is Grabbable:
				_grabbed_object = hit.collider as Grabbable
				_grabbed_object.grab()
				_is_grabbing = true

func _stop_grabbing():
	pass

func _cast_ray(distance: float = interact_distance) -> Dictionary:
	var origin := _camera.global_position
	var target := origin + (-_camera.global_transform.basis.z * distance)
	var query := PhysicsRayQueryParameters3D.create(origin, target)
	query.exclude = [self]
	
	return get_world_3d().direct_space_state.intersect_ray(query)
