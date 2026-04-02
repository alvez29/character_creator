class_name GrabbingBehaviorComponent
extends Node3D

signal has_grabbed_something
signal has_released_something

@export var grabbing_pivot: Marker3D
@export var grabbing_distance: float = 7.0
@export_flags_3d_physics var grabbing_collision_mask

@onready var _grabbing_joint: Generic6DOFJoint3D = %GrabbingJoint

var _grabbing_object: Grabbable
var _is_grabbing = false

func _ready() -> void:
	var remote_transform = RemoteTransform3D.new()
	grabbing_pivot.add_child(remote_transform)
	remote_transform.update_position = true
	remote_transform.update_rotation = true
	remote_transform.update_scale = false
	remote_transform.remote_path = get_path()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("movement_grab"):
		if _is_grabbing:
			_stop_grabbing()
		else:
			_try_grab()

func _try_grab():
	var origin = get_viewport().get_camera_3d().global_position
	var target = origin + (-get_viewport().get_camera_3d().global_transform.basis.z * grabbing_distance)
	var hit = Utils._cast_ray(get_world_3d(), origin, target, grabbing_collision_mask)
	
	if hit and hit.collider is Grabbable:
		_grabbing_object = hit.collider
		_grabbing_object.grab()
		_grabbing_joint.node_b = _grabbing_object.get_path()
		_is_grabbing = true
		has_grabbed_something.emit()


func _stop_grabbing():
	if _grabbing_object:
		_grabbing_joint.node_b = NodePath("")
		_grabbing_object.release()
		_is_grabbing = false
		has_released_something.emit()
