class_name EyesVisualUpdater
extends VisualUpdater

@export var l_eye_mesh: MeshInstance3D
@export var r_eye_mesh: MeshInstance3D

@export var eyes_pivot: Node3D

@export var l_eye_pivot: Node3D
@export var r_eye_pivot: Node3D

var _initial_eyes_height: float

func initialize(manager: CharacterCreatorManager):
	if eyes_pivot:
		_initial_eyes_height = eyes_pivot.position.y
	
	manager.character_data.eyes_size.reactive_changed.connect(_on_eyes_size_changed)
	manager.character_data.eyes_rotation.reactive_changed.connect(_on_eyes_rotation_changed)
	manager.character_data.eyes_separation.reactive_changed.connect(_on_eyes_separation_changed)
	manager.character_data.eyes_height.reactive_changed.connect(_on_eyes_height_changed)

func load_character_data(character_data: CharacterData):
	set_eyes_separation(character_data.eyes_separation.value)
	set_eyes_rotation(character_data.eyes_rotation.value)
	set_eyes_size(character_data.eyes_size.value)
	set_eyes_height(character_data.eyes_height.value)


#region Events
func _on_eyes_size_changed(reactive: ReactiveFloat) -> void:
	var eyes_size = reactive.value
	set_eyes_size(eyes_size)


func _on_eyes_rotation_changed(reactive: ReactiveFloat) -> void:
	var eyes_rotation = reactive.value
	set_eyes_rotation(eyes_rotation)


func _on_eyes_separation_changed(reactive: ReactiveFloat) -> void:
	set_eyes_separation(reactive.value)


func _on_eyes_height_changed(reactive: ReactiveFloat) -> void:
	set_eyes_height(reactive.value)
#endregion

#region Modifiers
func set_eyes_separation(value: float):
	if l_eye_pivot:
		l_eye_pivot.position.x = - value / 2
	
	if r_eye_pivot:
		r_eye_pivot.position.x = value / 2


func set_eyes_rotation(value: float):
	if l_eye_pivot:
		l_eye_pivot.rotation.z = value
		
	if r_eye_pivot:
		r_eye_pivot.rotation.z = -value


func set_eyes_size(value: float):
	var eye_size = Vector2(value, value)
	
	if l_eye_mesh:
		l_eye_mesh.mesh.size = eye_size
	
	if r_eye_mesh:
		r_eye_mesh.mesh.size = eye_size


func set_eyes_height(value: float):
	if eyes_pivot:
		eyes_pivot.position.y = _initial_eyes_height + value

#endregion
