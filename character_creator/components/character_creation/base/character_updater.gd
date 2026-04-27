class_name CharacterUpdater
extends Node

@export var updaters: Array[VisualUpdater] = []

#region Public methods
func initialize(manager: CharacterCreatorManager) -> void:
	_try_loading_loaders_children()
	
	for updater: VisualUpdater in updaters:
		updater.initialize(manager)


func load_character_data(character_data: CharacterData):
	_try_loading_loaders_children()
	
	for updater: VisualUpdater in updaters:
		updater.load_character_data(character_data)
#endregion

#region Private methods
func _try_loading_loaders_children():
	if updaters.is_empty():
		for child in get_children():
			if child is VisualUpdater: updaters.append(child)
#endregion
