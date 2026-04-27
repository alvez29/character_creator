class_name CharacterCreatorManager
extends Node

@export var character_updater: CharacterUpdater
@export var character_ui: CharacterCreatorUI

@export var creation_settings: CharacterCreationSettings
@export var character_data: CharacterData

# here code order matters!!!
func _ready() -> void:
	if not character_data:
		character_data = CharacterData.new()
	
	if not creation_settings:
		push_error("You need to set up the creation settins")
	
	creation_settings.load_equivalences()

	if character_updater:
		character_updater.initialize(self)
	else:
		push_warning("CharacterCreatorManager: No character_viewer assigned.")
		
	if character_ui:
		character_ui.initialize(self)
	else:
		push_warning("CharacterCreatorManager: No character_ui assigned.")
