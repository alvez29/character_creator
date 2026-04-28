class_name CharacterCreatorManager
extends Node

@export var character_updater: CharacterUpdater
@export var character_ui: CharacterCreatorUI

@export var creation_profile: CharacterCreationProfile
@export var character_data: CharacterData


func _ready() -> void:
	if not character_data:
		character_data = CharacterData.new()
	
	if not creation_profile:
		push_error("You need to set up the creation settings")
		return
	
	creation_profile.load_equivalences()

	if character_updater:
		character_updater.initialize(self)
	else:
		push_warning("CharacterCreatorManager: No character_updater assigned.")
		
	if character_ui:
		character_ui.initialize(self)
	else:
		push_warning("CharacterCreatorManager: No character_ui assigned.")

func load_character_data(data: CharacterData) -> void:
	character_data.eyes_size.value       = data.eyes_size.value
	character_data.eyes_separation.value = data.eyes_separation.value
	character_data.eyes_rotation.value   = data.eyes_rotation.value
	character_data.eyes_height.value     = data.eyes_height.value
	character_data.eyes_flattening.value = data.eyes_flattening.value
	character_data.eye_texture.value     = data.eye_texture.value
	
	character_data.mouth_size.value      = data.mouth_size.value
	character_data.mouth_height.value    = data.mouth_height.value
	character_data.mouth_flattening.value= data.mouth_flattening.value
	character_data.mouth_texture.value   = data.mouth_texture.value
	
	character_data.head_mesh.value       = data.head_mesh.value
	character_data.skin_color.value      = data.skin_color.value
	
	character_data.eyebrows_size.value       = data.eyebrows_size.value
	character_data.eyebrows_separation.value = data.eyebrows_separation.value
	character_data.eyebrows_rotation.value   = data.eyebrows_rotation.value
	character_data.eyebrows_height.value     = data.eyebrows_height.value
	character_data.eyebrows_flattening.value = data.eyebrows_flattening.value
	character_data.eyebrows_texture.value    = data.eyebrows_texture.value
	character_data.eyebrows_color.value      = data.eyebrows_color.value
