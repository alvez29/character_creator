class_name MouthVisualUpdater
extends VisualUpdater

@export var mouth_pivot: Node3D
@export var mouth_mesh: MeshInstance3D

var _initial_mouth_height

func _ready() -> void:
	_initial_mouth_height = mouth_mesh.position.y

func initialize(manager: CharacterCreatorManager):
	manager.character_data.mouth_size.reactive_changed.connect(
		_on_mouth_size_changed.bind(manager.character_data.mouth_flattening))
	manager.character_data.mouth_height.reactive_changed.connect(_on_mouth_height_changed)
	manager.character_data.mouth_flattening.reactive_changed.connect(
		_on_mouth_flattening_changed.bind(manager.character_data.mouth_size))
	manager.character_data.mouth_texture.reactive_changed.connect(_on_mouth_texture_changed)
	


func load_character_data(character_data: CharacterData):
	set_mouth_size(character_data.mouth_size.value, character_data.mouth_flattening.value)
	set_mouth_height(character_data.mouth_height.value)
	set_mouth_texture(character_data.mouth_texture.value)


func _on_mouth_texture_changed(reactive: ReactiveTexture):
	set_mouth_texture(reactive.value)


func _on_mouth_size_changed(size: ReactiveFloat, flattening: ReactiveFloat):
	set_mouth_size(size.value, flattening.value)


func _on_mouth_height_changed(reactive: ReactiveFloat):
	set_mouth_height(reactive.value)


func _on_mouth_flattening_changed(flattening: ReactiveFloat, size: ReactiveFloat):
	set_mouth_size(size.value, flattening.value)


func set_mouth_size(size: float, flattening: float):
	if mouth_mesh:
		mouth_mesh.mesh.size.x = size
		mouth_mesh.mesh.size.y = size * flattening


func set_mouth_height(value: float):
	if mouth_mesh:
		mouth_mesh.position.y = _initial_mouth_height + value


func set_mouth_flattening(value: float, actual_size_value: float):
	if mouth_mesh:
		mouth_mesh.mesh.size.y = actual_size_value * value


func set_mouth_texture(value: Texture2D):
	if mouth_mesh:
		(mouth_mesh.get_active_material(0) as ShaderMaterial).set_shader_parameter("texture_albedo", value)
