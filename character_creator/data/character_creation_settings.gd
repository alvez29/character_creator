class_name CharacterCreationSettings
extends Resource

#region Eyes Settings
@export_group("Eyes")
@export_subgroup("Separation")
@export var eyes_separation_steps: int = 10
@export var min_eyes_separation: float = 0.2
@export var max_eyes_separation: float = 0.8

@export_subgroup("Size")
@export var eyes_size_steps: int = 10
@export var min_scale_eyes_size: float = 0.2
@export var max_scale_eyes_size: float = 2

@export_subgroup("Rotation")
@export var eyes_rotation_steps: int = 10
@export var min_eyes_rotation_deg: float = -45.0
@export var max_eyes_rotation_deg: float = 45.0

@export_subgroup("Height")
@export var eyes_height_steps: int = 10
@export var min_eyes_height: float = -1
@export var max_eyes_height: float = 1

@export_subgroup("Resources")
@export var textures: Array[Texture2D]


## equivalences. these needs to be loaded runtime
var eyes_separation_equivalence: Dictionary
var eyes_size_equivalence: Dictionary
var eyes_rotation_equivalence: Dictionary
var eyes_height_equivalence: Dictionary


func load_equivalences():
	load_eyes_separation_equivalence()
	load_eyes_size_equivalence()
	load_eyes_rotation_equivalence()
	load_eyes_height_equivalence()


func load_eyes_separation_equivalence():
	eyes_separation_equivalence.clear()
	
	# from 0 to eyes_separation_steps - 1
	for i in range(eyes_separation_steps):
		eyes_separation_equivalence[i] = calculate_range_parts(min_eyes_separation, max_eyes_separation, eyes_separation_steps, i)


func load_eyes_size_equivalence():
	eyes_size_equivalence.clear()
	
	# from 0 to eyes_size_steps - 1
	for i in range(eyes_size_steps):
		eyes_size_equivalence[i] = calculate_range_parts(min_scale_eyes_size, max_scale_eyes_size, eyes_size_steps, i)


func load_eyes_rotation_equivalence():
	eyes_rotation_equivalence.clear()
	
	for i in range(eyes_rotation_steps):
		eyes_rotation_equivalence[i] = calculate_range_parts(deg_to_rad(min_eyes_rotation_deg), deg_to_rad(max_eyes_rotation_deg), eyes_rotation_steps, i)


func load_eyes_height_equivalence():
	eyes_height_equivalence.clear()
	
	for i in range(eyes_height_steps):
		eyes_height_equivalence[i] = calculate_range_parts(min_eyes_height, max_eyes_height, eyes_height_steps, i)


func calculate_range_parts(min_value, max_value, max_index, current_index) -> float:
	var normalized_value = lerp(min_value, max_value, float(current_index) / (max_index - 1))
	return snapped(normalized_value, 0.01)
