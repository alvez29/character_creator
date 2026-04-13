## Main component to enable grasping physics and dropping objects.
## Relies on a Generic6DOFJoint3D and MetaComponent discovery to attach objects.
class_name GrabbingBehaviorComponent
extends Node3D

signal has_grabbed_something
signal has_released_something

@export var grabbing_pivot: Marker3D
@export var grabbing_distance: float = 7.0
@export_flags_3d_physics var grabbing_collision_mask

@onready var _grabbing_joint: Generic6DOFJoint3D = %GrabbingJoint

var _grabbing_object: GrabbableComponent
var is_grabbing = false
var _snap_to_anchor_tween: Tween

func _ready() -> void:
	var remote_transform = RemoteTransform3D.new()
	grabbing_pivot.add_child(remote_transform)
	remote_transform.update_position = true
	remote_transform.update_rotation = true
	remote_transform.update_scale = false
	remote_transform.remote_path = get_path()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("movement_grab"):
		if is_grabbing:
			_stop_grabbing()
		else:
			_try_grab()

func _try_grab():
	var origin = get_viewport().get_camera_3d().global_position
	var target = origin + (-get_viewport().get_camera_3d().global_transform.basis.z * grabbing_distance)
	var hit = Utils.Physics.intersect_ray(get_world_3d(), origin, target, grabbing_collision_mask)
	
	if hit and hit.collider:
		var collider = hit.collider
		var grabbable = GrabbableComponent.get_grabbable_component_or_null(collider)
		
		if grabbable and grabbable.target_body:
			_grabbing_object = grabbable
			_grabbing_object.grab()
			
			snap_object_to_position()


func snap_object_to_position():
	if _snap_to_anchor_tween: _snap_to_anchor_tween.kill()
	
	_snap_to_anchor_tween = create_tween()
	_snap_to_anchor_tween.set_trans(Tween.TRANS_SINE)
	_snap_to_anchor_tween.set_ease(Tween.EASE_OUT)
	_snap_to_anchor_tween.tween_property(_grabbing_object.target_body, "global_position", _grabbing_joint.global_position, 0.1)
	_snap_to_anchor_tween.tween_callback(_on_object_snapped)
	

func _on_object_snapped():
	_grabbing_object.target_body.global_position = _grabbing_joint.global_position
	_grabbing_joint.node_b = _grabbing_object.target_body.get_path()
	is_grabbing = true
	has_grabbed_something.emit()


func _stop_grabbing():
	if _grabbing_object:
		_grabbing_joint.node_b = NodePath("")
		_grabbing_object.release()
		is_grabbing = false
		has_released_something.emit()
