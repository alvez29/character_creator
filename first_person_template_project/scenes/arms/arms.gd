class_name Arms
extends Node3D

@onready var update_timer: Timer = $UpdateTimer
@onready var relax_timer: Timer = $RelaxTimer
@onready  var skeleton: Skeleton3D = $Skeleton3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree

@export var update_time: float = 0.1
@export var relax_time: float = 4.0
@export var player: Player

var is_standing: bool = true
var is_punching_on_queue: bool = false
var should_relax: bool = false
var should_punch_with_left_arm: bool = true

func _ready() -> void:
	update_timer.wait_time = update_time
	relax_timer.wait_time = relax_time
	
	update_timer.start()
	player.punching_behavior_component.on_punch_command.connect(on_punch_command_called)
	should_punch_with_left_arm = true


func _on_update_timer_timeout() -> void:
	if player:
		animation_tree.set("parameters/conditions/relax_to_jab_l", is_punching_on_queue and should_punch_with_left_arm)
		animation_tree.set("parameters/conditions/relax_to_jab_r", is_punching_on_queue and not should_punch_with_left_arm)
		animation_tree.set("parameters/conditions/guard_to_jab_l", is_punching_on_queue and should_punch_with_left_arm)
		animation_tree.set("parameters/conditions/guard_to_jab_r", is_punching_on_queue and not should_punch_with_left_arm)
		animation_tree.set("parameters/conditions/guard_to_relax", should_relax and not is_punching_on_queue)



func on_punch_command_called():
	is_punching_on_queue = true


func execute_punch():
	var bone_idx = skeleton.find_bone("hand.R" if should_punch_with_left_arm else "hand.L")
	var bone_transform = skeleton.get_bone_global_pose(bone_idx)
	var bone_position = bone_transform.origin
	var bone_global_position = to_global(bone_position)
	
	player.punching_behavior_component.punch(get_world_3d(), bone_global_position)


func _on_animation_tree_animation_started(anim_name: StringName) -> void:
	match anim_name:
		"ArmsRig|Jab_L":
			should_relax = false
			is_punching_on_queue = false
			should_punch_with_left_arm = false
		"ArmsRig|Jab_R":
			should_relax = false
			is_punching_on_queue = false
			should_punch_with_left_arm = true


func _on_relax_timer_timeout() -> void:
	should_relax = true
	should_punch_with_left_arm = true


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"ArmsRig|Jab_L":
			relax_timer.start()
		"ArmsRig|Jab_R":
			relax_timer.start()
