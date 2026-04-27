class_name SkinVisualUpdater
extends VisualUpdater

# TODO: update with all visual dependences of skin color

@export var face_mesh: MeshInstance3D

func initialize(manager: CharacterCreatorManager):
	manager.character_data.skin_color.reactive_changed.connect(_on_skin_color_changed)


func load_character_data(character_data: CharacterData):
	set_skin_color(character_data.skin_color.value)

#region Events
func _on_skin_color_changed(reactive: ReactiveColor) -> void:
	set_skin_color(reactive.value)
#endregion


#region Modifiers
func set_skin_color(color: Color):
	if face_mesh and face_mesh.mesh:
		var face_material = face_mesh.get_surface_override_material(0) as StandardMaterial3D
		face_material.albedo_color = color
#endregion
