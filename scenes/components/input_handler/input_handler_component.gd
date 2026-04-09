class_name InputHandlerComponent
extends Node

signal crouch_pressed
signal crouch_released

@export var is_active := false

var movement_dir := Vector2.ZERO
var is_sprinting := false
var is_jumping := false
var is_crouching := false

var accelerate := 0.0
var brake := 0.0
var steering := 0.0
var handbrake := false

# Acumulador para movimiento de mouse
# _unhandled_input se ejecuta de forma asíncrona/irregular, causando jitter
# Acumulamos los deltas y los consumimos en _process() para rotación fluida y sin lag
var _mouse_delta_accumulated := Vector2.ZERO


func _unhandled_input(event: InputEvent) -> void:
	if not is_active: return
	
	if event.is_action_pressed("movement_crouch"):
		emit_signal("crouch_pressed")
	elif event.is_action_released("movement_crouch"):
		emit_signal("crouch_released")
		
	# Solo acumular el delta del mouse, NO emitir señal aquí
	# _unhandled_input es asíncrono -> causa jitter
	# El delta se consume en _process() para aplicación directa sin interpolación
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_mouse_delta_accumulated += event.relative


func _reset_state():
	movement_dir = Vector2.ZERO
	is_sprinting = false
	is_jumping = false
	is_crouching = false
	_mouse_delta_accumulated = Vector2.ZERO


func process_inputs() -> void:
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


# Obtiene y resetea el delta acumulado del mouse
# Patrón: Acumular en _unhandled_input -> Consumir en _process() -> Aplicar directamente (sin SLERP/interpolación)
func consume_mouse_delta() -> Vector2:
	var delta = _mouse_delta_accumulated
	_mouse_delta_accumulated = Vector2.ZERO
	return delta
