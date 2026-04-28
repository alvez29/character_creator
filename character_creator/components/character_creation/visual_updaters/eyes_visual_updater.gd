class_name EyesVisualUpdater
extends VisualUpdater

@export var l_eye_mesh: MeshInstance3D
@export var r_eye_mesh: MeshInstance3D

@export var eyes_pivot: Node3D

@export var l_eye_pivot: Node3D
@export var r_eye_pivot: Node3D

var _initial_eyes_height: float

func _ready() -> void:
	if eyes_pivot:
		_initial_eyes_height = eyes_pivot.position.y


func initialize(manager: CharacterCreatorManager) -> void:
	manager.character_data.eyes_size.reactive_changed.connect(_on_eyes_size_changed.bind(manager.character_data.eyes_flattening))
	manager.character_data.eyes_rotation.reactive_changed.connect(_on_eyes_rotation_changed)
	manager.character_data.eyes_separation.reactive_changed.connect(_on_eyes_separation_changed)
	manager.character_data.eyes_height.reactive_changed.connect(_on_eyes_height_changed)
	manager.character_data.eyes_flattening.reactive_changed.connect(_on_eyes_flattening_changed.bind(manager.character_data.eyes_size))
	manager.character_data.eye_texture.reactive_changed.connect(_on_eye_texture_changed)
	


func load_character_data(character_data: CharacterData) -> void:
	set_eyes_separation(character_data.eyes_separation.value)
	set_eyes_rotation(character_data.eyes_rotation.value)
	set_eyes_size(character_data.eyes_size.value, character_data.eyes_flattening.value)
	set_eyes_height(character_data.eyes_height.value)
	set_eye_texture(character_data.eye_texture.value)


#region Events
func _on_eyes_size_changed(size: ReactiveFloat, flattening: ReactiveFloat) -> void:
	set_eyes_size(size.value, flattening.value)


func _on_eyes_rotation_changed(reactive: ReactiveFloat) -> void:
	set_eyes_rotation(reactive.value)


func _on_eyes_separation_changed(reactive: ReactiveFloat) -> void:
	set_eyes_separation(reactive.value)


func _on_eyes_height_changed(reactive: ReactiveFloat) -> void:
	set_eyes_height(reactive.value)


func _on_eyes_flattening_changed(flattening: ReactiveFloat, size: ReactiveFloat) -> void:
	set_eyes_size(size.value, flattening.value)


func _on_eye_texture_changed(reactive: ReactiveTexture) -> void:
	set_eye_texture(reactive.value)
#endregion


#region Modifiers
func set_eyes_separation(value: float) -> void:
	if l_eye_pivot:
		l_eye_pivot.position.x = -value / 2
	if r_eye_pivot:
		r_eye_pivot.position.x = value / 2


func set_eyes_rotation(value: float) -> void:
	if l_eye_pivot:
		l_eye_pivot.rotation.z = value
	if r_eye_pivot:
		r_eye_pivot.rotation.z = -value


func set_eyes_size(size: float, flattening: float) -> void:
	if l_eye_mesh:
		l_eye_mesh.mesh.size.x = size
		l_eye_mesh.mesh.size.y = size * flattening
	if r_eye_mesh:
		r_eye_mesh.mesh.size.x = size
		r_eye_mesh.mesh.size.y = size * flattening


func set_eyes_height(value: float) -> void:
	if eyes_pivot:
		eyes_pivot.position.y = _initial_eyes_height + value


func set_eye_texture(texture: Texture2D) -> void:
	if l_eye_mesh:
		(l_eye_mesh.get_active_material(0) as ShaderMaterial).set_shader_parameter("texture_albedo", texture)
	if r_eye_mesh:
		(r_eye_mesh.get_active_material(0) as ShaderMaterial).set_shader_parameter("texture_albedo", texture)
#endregion
