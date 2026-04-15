class_name SphereVehicle
extends RigidBody3D

@export_category("Components")
@export var input_handler: InputHandlerComponent
@export var pawn_component: PawnComponent

@export_group("Speed")
@export var max_speed: float = 50.0
@export var acceleration: float = 120.0
var vehicle_linear_velocity: float = 0.0

@export_group("Sphere Mechanics")
@export var acceleration_torque: float = 400.0
@export var turning_speed: float = 4.5
@export var align_speed: float = 18.0
@export var jump_force: float = 12.0

@export_group("Nodes")
@export var visual_node: Node3D
@export var ground_raycast: RayCast3D

var _throttle: float = 0.0
var _steering_input: float = 0.0
var _current_visual_rotation: float = 0.0

@onready var _camera: Camera3D = %VehicleCamera

func _physics_process(delta: float) -> void:
	if input_handler:
		input_handler.process_movement_related_inputs()
	handle_vehicle_control(delta)
	handle_engine_velocity()
	_update_visuals(delta)
	
	# Arcade dampening to emulate tire friction
	if is_on_floor():
		if _throttle == 0:
			angular_damp = 15.0 # Frenado rápido simulando fricción de ruedas
			linear_damp = 2.0
		else:
			angular_damp = 2.0
			linear_damp = 0.5
	else:
		angular_damp = 1.0 # Control más ligero en el aire
		linear_damp = 0.1

func handle_engine_velocity() -> void:
	if not input_handler: return
	
	_throttle = input_handler.accelerate - input_handler.brake
	vehicle_linear_velocity = linear_velocity.length()
	
	var speed_factor = 1.0 - min(vehicle_linear_velocity / max_speed, 1.0)
	
	if _throttle != 0:
		# Calculate forward direction based on visual node's rotation
		var forward_dir = -visual_node.global_transform.basis.z.normalized()
		# Applying torque perpendicular to forward to create rolling motion
		var torque_dir = forward_dir.cross(Vector3.UP).normalized()
		apply_torque(-torque_dir * _throttle * acceleration_torque * speed_factor)

func handle_handbrake() -> void:
	pass

func handle_vehicle_control(delta: float) -> void:
	if not input_handler: return
	
	_steering_input = -input_handler.steering
	_current_visual_rotation += _steering_input * turning_speed * delta

	# Handle jump if pawn component is not attached, but standard project inputs might just be jumping?
	if input_handler.is_jumping and is_on_floor():
		apply_central_impulse(Vector3.UP * jump_force)

func is_on_floor() -> bool:
	if ground_raycast:
		return ground_raycast.is_colliding()
	return false

func _update_visuals(delta: float) -> void:
	if not visual_node: return
	
	# Keep visual node at sphere position, but don't inherit its pitch/roll rotation
	visual_node.global_position = global_position
	
	var target_up = Vector3.UP
	if is_on_floor():
		target_up = ground_raycast.get_collision_normal()
	
	# Align visual node to ground normal
	var current_basis = visual_node.global_transform.basis
	# Define a new basis based on target up and our desired Y rotation
	
	var desired_forward = Vector3.FORWARD.rotated(Vector3.UP, _current_visual_rotation).normalized()
	var right = target_up.cross(desired_forward).normalized()
	
	if right.length_squared() > 0.01:
		var forward = right.cross(target_up).normalized()
		var target_basis = Basis(right, target_up, forward)
		
		# Slerp the rotation for smooth alignment
		visual_node.global_transform.basis = current_basis.slerp(target_basis, delta * align_speed).orthonormalized()
