## Component handling the player's arms procedural animation, state transitions, and triggering punches.
class_name Arms
extends Node3D

enum AnimationMode { TREE, IK }

@onready var update_timer: Timer = $UpdateTimer
@onready var relax_timer: Timer = $RelaxTimer
@onready  var skeleton: Skeleton3D = $Skeleton3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree

@onready var r_hand_ik_target: Marker3D = $RHandTarget
@onready var l_hand_ik_target: Marker3D = $LHandTarget

@export var update_time: float = 0.1
@export var relax_time: float = 2.0
@export var player: Player
@export var animation_mode: AnimationMode = AnimationMode.TREE
@export var ik_solver: IKModifier3D

var is_standing: bool = true
var should_charge_punch: bool = false
var should_relax: bool = false
var should_punch_with_left_arm: bool = true
var should_punch: bool = false

func _ready() -> void:
	update_timer.wait_time = update_time
	relax_timer.wait_time = relax_time
	
	match  animation_mode:
		AnimationMode.TREE:
			animation_tree.active = true
			ik_solver.active = false
		AnimationMode.IK:
			animation_tree.active = false
			ik_solver.active = true
			
	
	update_timer.start()
	player.punching_behavior_component.on_charging_punch.connect(on_punch_charge)
	player.punching_behavior_component.on_released_hold_punch.connect(on_hold_punch_released)
	player.punching_behavior_component.on_punch_started_pressed.connect(on_punch)
	should_punch_with_left_arm = true


func on_punch_charge():
	should_charge_punch = true
	should_relax = false
	if relax_timer: relax_timer.stop()
	_reload_parameters()

func on_hold_punch_released():
	should_charge_punch = false

func on_punch():
	should_punch = true
	_reload_parameters()

func _reload_parameters():
	if player:
		animation_tree.set("parameters/conditions/relax_charge_punch_l", should_charge_punch and should_punch_with_left_arm)
		animation_tree.set("parameters/conditions/relax_charge_punch_r", should_charge_punch and not should_punch_with_left_arm)
		animation_tree.set("parameters/conditions/charge_punch_l_punch_l", should_punch and should_punch_with_left_arm)
		animation_tree.set("parameters/conditions/charge_punch_r_punch_r", should_punch and not should_punch_with_left_arm)
		animation_tree.set("parameters/conditions/guard_charge_punch_l", should_charge_punch and should_punch_with_left_arm)
		animation_tree.set("parameters/conditions/guard_charge_punch_r", should_charge_punch and not should_punch_with_left_arm)
		animation_tree.set("parameters/conditions/charge_punch_l_relax", not should_charge_punch)
		animation_tree.set("parameters/conditions/charge_punch_r_relax", not should_charge_punch)
		animation_tree.set("parameters/conditions/guard_relax", should_relax)


func _on_update_timer_timeout() -> void:
	_reload_parameters()


func execute_punch():
	relax_timer.start()
	should_punch_with_left_arm = not should_punch_with_left_arm
	
	var bone_idx = skeleton.find_bone("hand.R" if should_punch_with_left_arm else "hand.L")
	var bone_transform = skeleton.get_bone_global_pose(bone_idx)
	var bone_position = bone_transform.origin
	var bone_global_position = to_global(bone_position)
	
	var punch_direction = -player.camera_pivot.global_transform.basis.z if player.camera_pivot else -player.global_transform.basis.z
	
	player.punching_behavior_component.punch(get_world_3d(), bone_global_position, punch_direction)
	should_punch = false


func _on_relax_timer_timeout() -> void:
	should_relax = true
