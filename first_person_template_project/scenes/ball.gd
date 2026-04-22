extends RigidBody3D

@onready var punchable_component = $PunchableComponent
@onready var shaker_component = $ShakerComponent

func _ready() -> void:
	punchable_component.on_being_punched.connect(on_being_punched)

func on_being_punched(charge_factor: float):
	shaker_component.add_trauma(charge_factor * 1)
	shaker_component.on_shake_finished.connect(on_shake_completed)

func on_shake_completed():
	punchable_component.execute_punch()
	shaker_component.on_shake_finished.disconnect(on_shake_completed)
