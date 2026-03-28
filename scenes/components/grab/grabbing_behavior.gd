class_name GrabbingBehaviorComponent
extends Node3D

signal has_grabbed_something
signal has_released_something

@export var grabbing_pivot: Marker3D
@export var in_sight_checker_component: InSightCheckerComponent

@onready var _grabbing_joint: Generic6DOFJoint3D = %GrabbingJoint

var _grabbing_object: Grabbable
var _grabbable_in_sight: Grabbable
var _is_grabbing = false

func _ready() -> void:
	var remote_transform = RemoteTransform3D.new()
	grabbing_pivot.add_child(remote_transform)
	remote_transform.update_position = true
	remote_transform.update_rotation = true
	remote_transform.update_scale = false
	remote_transform.remote_path = get_path()
	
	in_sight_checker_component.on_grababble_in_sight.connect(_on_grabbable_in_sight)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("grab"):
		if _is_grabbing:
			_stop_grabbing()
		else:
			_try_grab()


func _on_grabbable_in_sight(object: Grabbable):
	_grabbable_in_sight = object

func _try_grab():
	if _grabbable_in_sight:
		_grabbing_object = _grabbable_in_sight
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
