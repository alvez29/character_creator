## Main component to enable grasping physics and dropping objects.
## Relies on a Generic6DOFJoint3D and MetaComponent discovery to attach objects.
class_name GrabbingBehaviorComponent
extends Node3D

signal has_grabbed_something
signal has_released_something

@export var grabbing_pivot: Marker3D
@export var grabbing_distance: float = 7.0
@export_flags_3d_physics var grabbing_collision_mask
## Speed multiplier used to drive the object toward the grab joint before snapping.
@export var snap_pull_speed: float = 15.0
## Distance threshold at which the joint connects and grab is considered complete.
@export var snap_attach_threshold: float = 0.25

@onready var _grabbing_joint: Generic6DOFJoint3D = %GrabbingJoint

var _grabbing_object: GrabbableComponent
var is_grabbing := false
var _is_pulling := false

func _ready() -> void:
	var remote_transform = RemoteTransform3D.new()
	grabbing_pivot.add_child(remote_transform)
	remote_transform.update_position = true
	remote_transform.update_rotation = true
	remote_transform.update_scale = false
	remote_transform.remote_path = get_path()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("movement_grab"):
		if is_grabbing or _is_pulling:
			_stop_grabbing()
		else:
			_try_grab()

func _physics_process(_delta: float) -> void:
	if not _is_pulling:
		return
	
	var body: RigidBody3D = _grabbing_object.target_body as RigidBody3D
	if not body:
		_is_pulling = false
		return
	
	var target_pos: Vector3 = _grabbing_joint.global_position
	var offset: Vector3 = target_pos - body.global_position
	var distance: float = offset.length()
	
	if distance <= snap_attach_threshold:
		_on_object_snapped()
		return
	
	# Drive the body toward the joint via velocity — physics handles collisions.
	body.linear_velocity = offset.normalized() * snap_pull_speed
	body.angular_velocity = Vector3.ZERO

func _try_grab() -> void:
	var origin: Vector3 = get_viewport().get_camera_3d().global_position
	var target: Vector3 = origin + (-get_viewport().get_camera_3d().global_transform.basis.z * grabbing_distance)
	var hit = Utils.Physics.intersect_ray(get_world_3d(), origin, target, grabbing_collision_mask)
	
	if hit and hit.collider:
		var grabbable: GrabbableComponent = GrabbableComponent.get_grabbable_component_or_null(hit.collider)
		
		if grabbable and grabbable.target_body:
			_grabbing_object = grabbable
			_grabbing_object.grab()
			_is_pulling = true


func _on_object_snapped() -> void:
	_is_pulling = false
	_grabbing_joint.node_b = _grabbing_object.target_body.get_path()
	is_grabbing = true
	has_grabbed_something.emit()


func _stop_grabbing() -> void:
	_is_pulling = false
	if _grabbing_object:
		_grabbing_joint.node_b = NodePath("")
		_grabbing_object.release()
		_grabbing_object = null
		is_grabbing = false
		has_released_something.emit()
