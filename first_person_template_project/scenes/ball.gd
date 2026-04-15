extends RigidBody3D

@onready var punchable_component = $PunchableComponent
@onready var shaker_component = $ShakerComponent

func _ready() -> void:
	punchable_component.on_being_punched.connect(func(): shaker_component.add_trauma(1))
