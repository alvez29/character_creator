class_name MouthVisualUpdater
extends VisualUpdater

@export var mouth_pivot: Node3D
@export var mouth_mesh: MeshInstance3D

func initialize(manager: CharacterCreatorManager):
	manager.character_data.mouth_size.reactive_changed.connect(_on_mouth_size_changed)


func load_character_data(character_data: CharacterData):
	set_mouth_size(character_data.mouth_size.value)


func _on_mouth_size_changed(reactive: ReactiveFloat):
	set_mouth_size(reactive.value)


func set_mouth_size(value: float):
	if mouth_mesh:
		mouth_mesh.mesh.size = Vector2(value, value)
