## Component that allows an object to be punched, applying the physics impulse to its parent body.
class_name PunchableComponent
extends MetaComponent

signal on_being_punched(charge_factor: float)

static var punchable_meta_key = &"punchable"

@export
var impulse_factor: float = 1
@export
var should_be_executed_immediately = true

var _desired_target_position: Vector3
var _desired_punch_direction: Vector3
var _desired_impulse: float

static func get_puchable_component_or_null(subject):
	return subject.get_meta(punchable_meta_key) if subject.has_meta(punchable_meta_key) else null

func get_related_meta() -> StringName:
	return punchable_meta_key

func punch(punching_data: PunchingBehaviorComponent.PunchingCollisionData):
	if target_body is RigidBody3D:
		_desired_target_position = Vector3(punching_data.intersection_point)
		_desired_punch_direction = Vector3(punching_data.direction.normalized())
		_desired_impulse = punching_data.desired_impulse
		
		on_being_punched.emit(punching_data.charge_factor_before_punching)

		if should_be_executed_immediately:
			execute_punch()


func execute_punch():
	var offset = _desired_target_position - target_body.global_position
	var direction = _desired_punch_direction.normalized()
	
	target_body.apply_impulse(direction * _desired_impulse * impulse_factor, offset)
