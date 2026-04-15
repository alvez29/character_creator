## Follow-camera mount that smoothly interpolates transformation towards a defined spatial target.
extends SpringArm3D
@export var target: Node3D
@export var smooth_speed: float = 6.0

func _ready() -> void:
	top_level = true
	
	if target == null:
		target = get_parent()

func _physics_process(delta: float) -> void:
	if is_instance_valid(target):
		global_position = global_position.lerp(target.global_position, smooth_speed * delta)
		
		var target_rotation_y = target.global_rotation.y
		global_rotation.y = lerp_angle(global_rotation.y, target_rotation_y, smooth_speed * delta)
