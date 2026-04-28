class_name CharacterCreationProfile
extends Resource

#region Eyes
@export_group("Eyes")
@export var eyes_separation : RangeSetting
@export var eyes_size       : RangeSetting
@export var eyes_rotation   : RangeSetting
@export var eyes_height     : RangeSetting
@export var eyes_textures   : TextureSelectSetting
#endregion

#region Mouth
@export_group("Mouth")
@export var mouth_size     : RangeSetting
#endregion

#region Skin
@export_group("Skin")
@export var skin_colors: ColorSelectSetting
#endregion

## Initializes all runtime data structures (equivalence maps, lookup dicts).
## Must be called once before accessing any setting values — CharacterCreatorManager
## calls this in _ready().
func load_equivalences() -> void:
	for setting_prop in get_property_list():
		var setting = get(setting_prop.name)
		
		if setting is CharacterSetting: setting.load()
