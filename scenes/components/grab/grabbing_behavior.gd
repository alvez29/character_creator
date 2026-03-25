class_name GrabbingBehavior
extends Node3D

signal has_grabbed_something
signal has_released_something

@export var _camera: Camera3D
@export var interact_distance: float = 7

@onready var grabbing_joint: Generic6DOFJoint3D = %GrabbingJoint
@onready var grab_anchor: StaticBody3D = %GrabAnchor

var _grabbed_object: Grabbable
var _is_grabbing = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("grab"):
		if _is_grabbing:
			_stop_grabbing()
		else:
			_try_grab()


func _try_grab():
	var hit = _cast_ray()

	if hit and hit.collider is Grabbable and hit.collider is RigidBody3D:
		_grabbed_object = hit.collider
		
		_grabbed_object.grab()
		_attach_spring()
		_is_grabbing = true
		has_grabbed_something.emit()

func _attach_spring():
	grabbing_joint.node_b = _grabbed_object.get_path()


func _stop_grabbing():
	if _grabbed_object:
		grabbing_joint.node_b = NodePath("")
		_grabbed_object.release()
		_grabbed_object = null
		_is_grabbing = false
		has_released_something.emit()


func _cast_ray(distance: float = interact_distance) -> Dictionary:
	var origin := _camera.global_position
	var target := origin + (-_camera.global_transform.basis.z * distance)

	var query := PhysicsRayQueryParameters3D.create(origin, target)
	query.exclude = [self]

	return get_world_3d().direct_space_state.intersect_ray(query)
