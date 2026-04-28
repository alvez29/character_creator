## Abstract base for selectable options that have a stable string ID.
## The ID is the persistence key used in CharacterData — it must never
## change after .tres files are created.
## Naming convention: snake_case, e.g. "eye_almond", "skin_pale".
@abstract
class_name SelectOption
extends Resource

## Stable persistence key. NEVER change after .tres is created.
@export var id: StringName

## Label shown in the UI selector.
@export var display_name: String
