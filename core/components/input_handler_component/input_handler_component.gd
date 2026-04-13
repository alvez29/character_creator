## this script should be filled with custom actions to provide to other nodes

class_name InputHandlerComponent
extends Node

signal crouch_pressed
signal crouch_released
signal sprint_pressed
signal sprint_released
signal punch_pressed

@export var is_active := false

var movement_dir := Vector2.ZERO
var is_sprinting := false
var is_jumping := false
var is_crouching := false

var accelerate := 0.0
var brake := 0.0
var steering := 0.0
var handbrake := false

var _mouse_delta_accumulated := Vector2.ZERO


func _unhandled_input(event: InputEvent) -> void:
	if not is_active: return
	
	if event.is_action_pressed("movement_crouch"):
		crouch_pressed.emit()
	elif event.is_action_released("movement_crouch"):
		crouch_released.emit()
		
	if event.is_action_pressed("movement_sprint"):
		sprint_pressed.emit()
	elif event.is_action_released("movement_sprint"):
		sprint_released.emit()
	
	if event.is_action_pressed("action_punch"):
		punch_pressed.emit()
		
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_mouse_delta_accumulated += event.relative


func _reset_state():
	movement_dir = Vector2.ZERO
	is_sprinting = false
	is_jumping = false
	is_crouching = false
	_mouse_delta_accumulated = Vector2.ZERO


func process_movement_related_inputs() -> void:
	if not is_active:
		_reset_state()
		return
	
	movement_dir = Input.get_vector("movement_move_left", "movement_move_right", "movement_move_forward", "movement_move_backward")
	is_sprinting = Input.is_action_pressed("movement_sprint")
	is_jumping = Input.is_action_pressed("movement_jump")
	is_crouching = Input.is_action_pressed("movement_crouch")
	
	accelerate = Input.get_action_strength("vehicle_accelerate")
	brake = Input.get_action_strength("vehicle_brake")
	steering = Input.get_action_strength("vehicle_steer_right") - Input.get_action_strength("vehicle_steer_left")
	handbrake = Input.is_action_pressed("vehicle_handbrake")


func consume_mouse_delta() -> Vector2:
	var delta = _mouse_delta_accumulated
	_mouse_delta_accumulated = Vector2.ZERO
	return delta
