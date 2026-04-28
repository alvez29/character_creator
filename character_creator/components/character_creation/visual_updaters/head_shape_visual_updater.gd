class_name HeadShapeVisualUpdater
extends VisualUpdater

@export var head_mesh_instance: MeshInstance3D

func initialize(manager: CharacterCreatorManager):
	manager.character_data.head_mesh.reactive_changed.connect(_on_head_mesh_changed)


func load_character_data(character_data: CharacterData):
	set_head_mesh(character_data.head_mesh.value)


func _on_head_mesh_changed(reactive: Reactive):
	set_head_mesh(reactive.value)


func set_head_mesh(mesh: Mesh):
	if head_mesh_instance:
		head_mesh_instance.mesh = mesh
