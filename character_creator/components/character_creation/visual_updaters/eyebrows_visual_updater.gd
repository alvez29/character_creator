class_name EyebrowsVisualUpdater
extends VisualUpdater

@export var l_eyebrow_mesh: MeshInstance3D
@export var r_eyebrow_mesh: MeshInstance3D

@export var eyebrows_pivot: Node3D

@export var l_eyebrow_pivot: Node3D
@export var r_eyebrow_pivot: Node3D

var _initial_eyebrows_height: float

func _ready() -> void:
	if eyebrows_pivot:
		_initial_eyebrows_height = eyebrows_pivot.position.y


func initialize(manager: CharacterCreatorManager) -> void:
	manager.character_data.eyebrows_size.reactive_changed.connect(_on_eyebrows_size_changed.bind(manager.character_data.eyebrows_flattening))
	manager.character_data.eyebrows_separation.reactive_changed.connect(_on_eyebrows_separation_changed)
	manager.character_data.eyebrows_rotation.reactive_changed.connect(_on_eyebrows_rotation_changed)
	manager.character_data.eyebrows_height.reactive_changed.connect(_on_eyebrows_height_changed)
	manager.character_data.eyebrows_flattening.reactive_changed.connect(_on_eyebrows_flattening_changed.bind(manager.character_data.eyebrows_size))
	manager.character_data.eyebrows_texture.reactive_changed.connect(_on_eyebrows_texture_changed)
	manager.character_data.eyebrows_color.reactive_changed.connect(_on_eyebrows_color_changed)
	


func load_character_data(character_data: CharacterData) -> void:
	set_eyebrows_separation(character_data.eyebrows_separation.value)
	set_eyebrows_rotation(character_data.eyebrows_rotation.value)
	set_eyebrows_size(character_data.eyebrows_size.value, character_data.eyebrows_flattening.value)
	set_eyebrows_height(character_data.eyebrows_height.value)
	set_eyebrows_texture(character_data.eyebrows_texture.value)
	set_eyebrows_color(character_data.eyebrows_color.value)


#region Events
func _on_eyebrows_size_changed(size: ReactiveFloat, flattening: ReactiveFloat) -> void:
	set_eyebrows_size(size.value, flattening.value)


func _on_eyebrows_rotation_changed(reactive: ReactiveFloat) -> void:
	set_eyebrows_rotation(reactive.value)


func _on_eyebrows_separation_changed(reactive: ReactiveFloat) -> void:
	set_eyebrows_separation(reactive.value)


func _on_eyebrows_height_changed(reactive: ReactiveFloat) -> void:
	set_eyebrows_height(reactive.value)


func _on_eyebrows_flattening_changed(flattening: ReactiveFloat, size: ReactiveFloat) -> void:
	set_eyebrows_size(size.value, flattening.value)


func _on_eyebrows_texture_changed(reactive: ReactiveTexture) -> void:
	set_eyebrows_texture(reactive.value)


func _on_eyebrows_color_changed(reactive: ReactiveColor) -> void:
	set_eyebrows_color(reactive.value)
#endregion


#region Modifiers
func set_eyebrows_separation(value: float) -> void:
	if l_eyebrow_pivot:
		l_eyebrow_pivot.position.x = -value / 2
	if r_eyebrow_pivot:
		r_eyebrow_pivot.position.x = value / 2


func set_eyebrows_rotation(value: float) -> void:
	if l_eyebrow_pivot:
		l_eyebrow_pivot.rotation.z = value
	if r_eyebrow_pivot:
		r_eyebrow_pivot.rotation.z = -value


func set_eyebrows_size(size: float, flattening: float) -> void:
	if l_eyebrow_mesh:
		l_eyebrow_mesh.mesh.size.x = size
		l_eyebrow_mesh.mesh.size.y = size * flattening
	if r_eyebrow_mesh:
		r_eyebrow_mesh.mesh.size.x = size
		r_eyebrow_mesh.mesh.size.y = size * flattening


func set_eyebrows_height(value: float) -> void:
	if eyebrows_pivot:
		eyebrows_pivot.position.y = _initial_eyebrows_height + value


func set_eyebrows_texture(texture: Texture2D) -> void:
	if l_eyebrow_mesh:
		var mat = l_eyebrow_mesh.get_active_material(0)
		if mat is ShaderMaterial:
			mat.set_shader_parameter("texture_albedo", texture)
	if r_eyebrow_mesh:
		var mat = r_eyebrow_mesh.get_active_material(0)
		if mat is ShaderMaterial:
			mat.set_shader_parameter("texture_albedo", texture)


func set_eyebrows_color(color: Color) -> void:
	pass
	# TODO: Aplicar máscara
#endregion
