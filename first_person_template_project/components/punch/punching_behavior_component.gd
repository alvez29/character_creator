class_name PunchingBehaviorComponent
extends Node

signal on_punch_command


@export var input_handler_component: InputHandlerComponent
@export_flags_3d_physics var punching_collision_mask
@export var punching_radius: float = 1.0
@export var punching_cooldown: float = 1.0
@export var punching_impulse: float = 200.0
@export var torque_impulse: Vector3 = Vector3.ZERO
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


func punch(world: World3D, position: Vector3):
	var intersection = Utils.Physics.intersect_shape(world, position, punching_radius, punching_collision_mask)
	
	if not intersection.is_empty():
		var collider = intersection.collider
		var punchable_component: PunchableComponent = PunchableComponent.get_puchable_component_or_null(collider)
		var torque: Vector3 = Vector3.ZERO if collider is Vehicle else torque_impulse
		
		if punchable_component:
			var punchable_position = punchable_component.target_body.global_position
			punchable_component.punch(punchable_position, position, punching_impulse, torque)


func _on_cooldown_timer_timeout():
	_can_punch = true
	
