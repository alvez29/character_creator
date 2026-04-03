class_name Vehicle
extends VehicleBody3D

var throttle: float = 0.0
var steering_input: float = 0.0

@export_group("Wheels")
@export var front_left_wheel: VehicleWheel3D
@export var front_right_wheel: VehicleWheel3D
@export var rear_left_wheel: VehicleWheel3D
@export var rear_right_wheel: VehicleWheel3D

@export_group("Speed")
@export var max_speed: float = 50.0
@export var acceleration: float = 120.0
var vehicle_linear_velocity: float = 0.0

@export_group("Steering & Break")
@export var steering_speed = 1.5
@export var max_steering_angle = 0.5
@export var handbrake_force = 5.0
var handbrake: bool = false

@export_group("Suspension Settings")
@export var wheel_friction: float = 10.5
@export var suspension_stiff_value: float = 50.0

@export_group("Stability Control")
@export var roll_influence: float = 0.5
var anti_roll_torque: Vector3
var downforce: Vector3
@export var anti_roll_force: float = 20.0 # Force to resist rolling
@export var downforce_factor: float = 50.0 # Pushes car down at speed

@onready
var _camera: Camera3D = %VehicleCamera


func _ready():
	pass

func _process(_delta: float) -> void:
	for wheel in [front_left_wheel, front_right_wheel, rear_left_wheel, rear_right_wheel]:
		wheel.wheel_friction_slip = wheel_friction # Lower for more drifting
		wheel.suspension_stiffness = suspension_stiff_value

func _physics_process(delta: float) -> void:
	handle_vehicle_control(delta)
	handle_engine_velocity()


func handle_engine_velocity():
	vehicle_linear_velocity = linear_velocity.length()
	var speed_factor = 1.0 - min(vehicle_linear_velocity / max_speed, 1.0)
	
	engine_force = throttle * acceleration * speed_factor


func handle_handbrake():
	brake = handbrake_force if handbrake else 0.0


func handle_vehicle_control(delta):
	throttle = Input.get_action_strength("vehicle_accelerate") - Input.get_action_strength("vehicle_brake")
	steering_input = Input.get_action_strength("vehicle_steer_right") - Input.get_action_strength("vehicle_steer_left")
	handbrake = Input.is_action_pressed("vehicle_handbrake")
	
	steering = move_toward(steering, -steering_input * max_steering_angle, delta * steering_speed)


func handle_anti_roll():
	anti_roll_torque = -global_transform.basis.z * global_rotation.z * anti_roll_force * max_speed
	apply_torque(anti_roll_torque)
	
	downforce = -global_transform.basis.y * vehicle_linear_velocity * downforce_factor
	apply_central_force(downforce)
	
	for wheel in [front_left_wheel, front_right_wheel, rear_left_wheel, rear_right_wheel]:
		wheel.wheel_roll_influence = roll_influence


func active_camera():
	_camera.current = true
