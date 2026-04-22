extends Node

@export_category("Components")
@export var movement_component: FirstPersonMovementComponent
@export var camera_shake: ShakerComponent
@export var punching_behavior: PunchingBehaviorComponent

@export_category("Shake")
@export var punching_camera_shake_preset: ShakeProfile
@export var sliding_camera_shake_preset: ShakeProfile

@export_category("Settings")
@export var should_hit_stop_when_punching := true
@export var punching_hit_stop_duration := 0.3

func _physics_process(_delta: float) -> void:
	update_camera_shake()


func _ready() -> void:
	if punching_behavior:
		punching_behavior.on_progress_updated.connect(_on_punching_progress_updated)
		punching_behavior.on_punch_collider_collided.connect(_on_punching_behavior_component_on_punch_collider_collided)

func _on_punching_behavior_component_on_punch_collider_collided(_punching_data: PunchingBehaviorComponent.PunchingCollisionData):
	if camera_shake:
		camera_shake.add_trauma(1, punching_camera_shake_preset)
		
	if should_hit_stop_when_punching:
		HitStopManager.frame_freeze(punching_hit_stop_duration)


func _on_punching_progress_updated(charging_progress: float):
	UIState.hud_state.punching_factor.value = charging_progress


func update_camera_shake():
	if movement_component.is_sliding:
			var min_s = movement_component.slide_min_speed
			var max_s = movement_component.sprint_max_speed + movement_component.slide_boost
			var intensity = clampf(remap(movement_component.body.speed, min_s, max_s, 0.0, 2.0), 0.0, 2.0)
			if camera_shake:
				camera_shake.add_trauma(intensity, sliding_camera_shake_preset)
