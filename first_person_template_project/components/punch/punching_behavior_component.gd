class_name PunchingBehaviorComponent
extends Node

signal on_punch_command

@export_category("Setting")
@export var subject: Node3D
@export var input_handler_component: InputHandlerComponent
@export_flags_3d_physics var punching_collision_mask
@export var punching_radius: float = 1.5
@export var punching_cooldown: float = 1.0
@export var punching_impulse: float = 20.0
@export var torque_impulse: Vector3 = Vector3.ZERO
@export var particles: CPUParticles3D

@export_category("Self punch")
@export var should_punch_against_floor = false
@export_flags_3d_physics var punch_against_mask = 0x000000

@onready var cooldown_timer: Timer = $CooldownTimer
var _can_punch: bool = true

func _ready() -> void:
	if input_handler_component:
		input_handler_component.punch_pressed.connect(_on_punch_input_pressed)
	
	if cooldown_timer:
		cooldown_timer.wait_time = punching_cooldown
		cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)


func _on_punch_input_pressed():
	if _can_punch:
		on_punch_command.emit()
		cooldown_timer.start()
		_can_punch = false


func punch(world: World3D, position: Vector3, custom_direction: Vector3 = Vector3.ZERO):
	var intersection = Utils.Physics.intersect_shape_with_point(world, position, punching_radius, punching_collision_mask)
	
	if intersection.collided:
		var collider = intersection.collider
		
		if collider:
			var collisiton_layer = collider.collision_layer
			var should_punch_against = (punch_against_mask & collisiton_layer) == collisiton_layer
			if should_punch_against_floor and should_punch_against:
				Utils.Physics.apply_central_impulse(subject, intersection.normal * punching_impulse, false, subject.movement_component.mass)
				
			else:
				var punchable_component: PunchableComponent = PunchableComponent.get_puchable_component_or_null(collider)
			
				if punchable_component:
					var intersection_point = intersection.point
					
					var direction = custom_direction if custom_direction != Vector3.ZERO else (intersection_point - position)
					punchable_component.punch(intersection_point, direction, punching_impulse, torque_impulse)


func _on_cooldown_timer_timeout():
	_can_punch = true
