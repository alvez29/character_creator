## Abstract base for all character creation settings.
## Each setting is self-contained: it knows how to build its own runtime
## data structures (equivalence maps, lookup dictionaries, etc.) via load().
## CharacterCreationSettings calls load() on each setting during _ready().
@abstract
class_name CharacterSetting
extends Resource

enum Category { EYES, MOUTH, EYEBROWS, HEAD_SHAPE, SKIN }

@export
var category: Category
@export
var display_name: String

@abstract
func load() -> void
