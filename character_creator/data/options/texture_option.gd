## A selectable eye/face texture option with a stable string ID.
## Save each option as its own .tres file and add it to a TextureSelectSetting.
class_name TextureOption
extends SelectOption

## The texture projected by the eye Decal nodes.
@export var texture: Texture2D
