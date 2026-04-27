## Component responsible for capturing and exposing player input actions to other systems and nodes.
class_name InputHandlerComponent
extends Node

signal crouch_started_pressed
signal crouch_released
signal sprint_started_pressed
signal sprint_released
signal hold_punch_started_pressed
signal hold_punch_released
signal punch_started_pressed
signal select_inventory_slot(index: int)
signal next_inventory_slot
signal previous_inventory_slot

@export var is_active := false

var movement_dir := Vector2.ZERO
var is_sprinting := false
var is_jumping := false
var is_jump_just_pressed := false
var is_crouching := false

var accelerate := 0.0
var brake := 0.0
var steering := 0.0
var handbrake := false

var _mouse_delta_accumulated := Vector2.ZERO

var _input_configuration : Dictionary = {}


func _ready() -> void:
	initialize_configuration()


## Populates the dictionary with all mapped actions in InputMap, enabling them by default.
func initialize_configuration() -> void:
	_input_configuration.clear()
	for action in InputMap.get_actions():
		_input_configuration[action] = true


## Enables or disables an input action in the configuration.
func set_action_enabled(action: StringName, enabled: bool) -> void:
	if _input_configuration.has(action):
		_input_configuration[action] = enabled
	else:
		push_warning("InputHandlerComponent: Action '%s' not found in configuration." % action)


## Returns whether an action is enabled in the configuration.
func is_action_enabled(action: StringName) -> bool:
	return _input_configuration.get(action, false)


func _unhandled_input(event: InputEvent) -> void:
	if not is_active: return
	
	if is_action_enabled("movement_crouch"):
		if event.is_action_pressed("movement_crouch"):
			crouch_started_pressed.emit()
		elif event.is_action_released("movement_crouch"):
			crouch_released.emit()
	
	if is_action_enabled("movement_sprint"):
		if event.is_action_pressed("movement_sprint"):
			sprint_started_pressed.emit()
		elif event.is_action_released("movement_sprint"):
			sprint_released.emit()
	
	if is_action_enabled("action_hold_punch"):
		if event.is_action_pressed("action_hold_punch"):
			hold_punch_started_pressed.emit()
		elif event.is_action_released("action_hold_punch"):
			hold_punch_released.emit()
	
	if is_action_enabled("action_punch"):
		if event.is_action_pressed("action_punch"):
			punch_started_pressed.emit()
	
	if is_action_enabled("ui_next_inventory_slot"):
		if event.is_action_pressed("ui_next_inventory_slot"):
			next_inventory_slot.emit()
	
	if is_action_enabled("ui_previous_inventory_slot"):
		if event.is_action_pressed("ui_previous_inventory_slot"):
			previous_inventory_slot.emit()
	
	if is_action_enabled("ui_first_inventory_slot"):
		if event.is_action_pressed("ui_first_inventory_slot"):
			select_inventory_slot.emit(0)
	
	if is_action_enabled("ui_second_inventory_slot"):
		if event.is_action_pressed("ui_second_inventory_slot"):
			select_inventory_slot.emit(1)
	
	if is_action_enabled("ui_third_inventory_slot"):
		if event.is_action_pressed("ui_third_inventory_slot"):
			select_inventory_slot.emit(2)

	if is_action_enabled("ui_fourth_inventory_slot"):
		if event.is_action_pressed("ui_fourth_inventory_slot"):
			select_inventory_slot.emit(3)

	if is_action_enabled("ui_fifth_inventory_slot"):
		if event.is_action_pressed("ui_fifth_inventory_slot"):
			select_inventory_slot.emit(4)

	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_mouse_delta_accumulated += event.relative




func _reset_state() -> void:
	movement_dir = Vector2.ZERO
	is_sprinting = false
	is_jumping = false
	is_jump_just_pressed = false
	is_crouching = false
	
	accelerate = 0.0
	brake = 0.0
	steering = 0.0
	handbrake = false
	_mouse_delta_accumulated = Vector2.ZERO


func process_movement_related_inputs() -> void:
	if not is_active:
		_reset_state()
		return
	
	movement_dir = Input.get_vector("movement_move_left", "movement_move_right", "movement_move_forward", "movement_move_backward")
	if not is_action_enabled("movement_move_left") and movement_dir.x < 0: movement_dir.x = 0
	if not is_action_enabled("movement_move_right") and movement_dir.x > 0: movement_dir.x = 0
	if not is_action_enabled("movement_move_forward") and movement_dir.y < 0: movement_dir.y = 0
	if not is_action_enabled("movement_move_backward") and movement_dir.y > 0: movement_dir.y = 0
	
	is_sprinting = Input.is_action_pressed("movement_sprint") if is_action_enabled("movement_sprint") else false
	is_jumping = Input.is_action_pressed("movement_jump") if is_action_enabled("movement_jump") else false
	is_jump_just_pressed = Input.is_action_just_pressed("movement_jump") if is_action_enabled("movement_jump") else false
	is_crouching = Input.is_action_pressed("movement_crouch") if is_action_enabled("movement_crouch") else false
	
	accelerate = Input.get_action_strength("vehicle_accelerate") if is_action_enabled("vehicle_accelerate") else 0.0
	brake = Input.get_action_strength("vehicle_brake") if is_action_enabled("vehicle_brake") else 0.0
	
	var steer_right = Input.get_action_strength("vehicle_steer_right") if is_action_enabled("vehicle_steer_right") else 0.0
	var steer_left = Input.get_action_strength("vehicle_steer_left") if is_action_enabled("vehicle_steer_left") else 0.0
	steering = steer_right - steer_left
	
	handbrake = Input.is_action_pressed("vehicle_handbrake") if is_action_enabled("vehicle_handbrake") else false


func consume_mouse_delta() -> Vector2:
	var delta = _mouse_delta_accumulated
	_mouse_delta_accumulated = Vector2.ZERO
	return delta
