## Component that handles charging and releasing punches, applying directional force to PunchableComponent targets.
class_name PunchingBehaviorComponent
extends Node

signal on_charging_punch
signal on_released_hold_punch
signal on_punch_started_pressed
signal on_progress_updated(actual_progress)
signal on_punch_collider_collided(punching_data: PunchingBehaviorComponent.PunchingCollisionData)

@export_category("Setting")
@export var subject: Node3D
@export var input_handler_component: InputHandlerComponent
@export_flags_3d_physics var punching_collision_mask
@export var punching_radius: float = 1.5
@export var punching_cooldown: float = 1.0
@export var punching_impulse: float = 20.0
@export var particles: CPUParticles3D
@export var max_charge_time: float = 1.0

@export_category("Self punch")
@export var should_punch_against_floor = false
@export_flags_3d_physics var punch_against_mask = 0x000000

@onready var cooldown_timer: Timer = $CooldownTimer
var _can_punch: bool = true
var _is_charging_punch: bool = false
var _charge_time: float = 0.0
var _charge_factor: float = 0.0

func _ready() -> void:
	if input_handler_component:
		input_handler_component.hold_punch_started_pressed.connect(_on_hold_punch_input)
		input_handler_component.hold_punch_released.connect(_on_hold_punch_input_released)
		input_handler_component.punch_started_pressed.connect(_on_punch_input_started_pressed)
	
	if cooldown_timer and punching_cooldown > 0.0:
		cooldown_timer.wait_time = punching_cooldown
		cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)


func _process(delta: float) -> void:
	if _is_charging_punch:
		_charge_time += delta
	else:
		_charge_time -= delta
		
	_charge_time = clamp(_charge_time, 0, max_charge_time)
	_charge_factor = _charge_time / max_charge_time
	on_progress_updated.emit(_charge_factor)


func _on_hold_punch_input():
	on_charging_punch.emit()
	_is_charging_punch = true


func _on_hold_punch_input_released():
	on_released_hold_punch.emit()
	_is_charging_punch = false


func _on_punch_input_started_pressed():
	if _can_punch:
		on_punch_started_pressed.emit()

func punch(world: World3D, position: Vector3, custom_direction: Vector3 = Vector3.ZERO):
	if punching_cooldown > 0.0:
		cooldown_timer.start()
		_can_punch = false
	
	_charge_time = 0.0
	
	var intersection = Utils.Physics.intersect_shape_with_point(world, position, punching_radius, punching_collision_mask)
	
	if intersection.collided:
		var collider = intersection.collider
		var intersection_point = intersection.point
		var intersection_normal = intersection.normal
		
		if collider:
			var collisiton_layer = collider.collision_layer
			var should_punch_against = (punch_against_mask & collisiton_layer) == collisiton_layer
			
			
			if should_punch_against_floor and should_punch_against:
				Utils.Physics.apply_central_impulse(subject, intersection_normal * punching_impulse, false, subject.movement_component.mass)
				on_punch_collider_collided.emit(PunchingCollisionData.new(intersection_point, intersection_normal, _charge_factor, _charge_factor * punching_impulse))
				
			else:
				var punchable_component: PunchableComponent = PunchableComponent.get_puchable_component_or_null(collider)
			
				if punchable_component:
					var direction = custom_direction if custom_direction != Vector3.ZERO else (intersection_point - position)
					on_punch_collider_collided.emit(PunchingCollisionData.new(intersection_point, direction, _charge_factor, _charge_factor * punching_impulse))
					punchable_component.punch(PunchingCollisionData.new(intersection_point, direction, _charge_factor,  _charge_factor * punching_impulse))
		
		_charge_factor = 0.0
		on_progress_updated.emit(_charge_factor)
	

func _on_cooldown_timer_timeout():
	_can_punch = true


class PunchingCollisionData:
	var intersection_point := Vector3.ZERO
	var direction := Vector3.ZERO
	var charge_factor_before_punching := 0.0
	var desired_impulse := 20.0
	
	func _init(_intersection_point: Vector3, _direction: Vector3, _charge_factor_before_punching: float, _desired_impulse: float):
		self.intersection_point = _intersection_point
		self.direction = _direction
		self.charge_factor_before_punching = _charge_factor_before_punching
		self.desired_impulse = _desired_impulse
