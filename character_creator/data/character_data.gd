class_name CharacterData
extends Reactive

@export var default_texture: Texture2D
@export var default_mesh:    Mesh


#region Eyebrows
@export_category("Eyebrows")
@export var eyebrows_size       := ReactiveFloat.new(0, self)
@export var eyebrows_separation := ReactiveFloat.new(0, self)
@export var eyebrows_rotation   := ReactiveFloat.new(0, self)
@export var eyebrows_height     := ReactiveFloat.new(0, self)
@export var eyebrows_flattening := ReactiveFloat.new(0, self)
@export var eyebrows_texture    := ReactiveTexture.new(default_texture, self)
@export var eyebrows_color      := ReactiveColor.new(Color(1, 1, 1), self)
#endregion


#region Eyes
@export_category("Eyes")
@export var eyes_size       := ReactiveFloat.new(0, self)
@export var eyes_separation := ReactiveFloat.new(0, self)
@export var eyes_rotation   := ReactiveFloat.new(0, self)
@export var eyes_height     := ReactiveFloat.new(0, self)
@export var eyes_flattening := ReactiveFloat.new(0, self)
@export var eye_texture     := ReactiveTexture.new(default_texture, self)
#endregion

#region Mouth
@export_category("Mouth")
@export var mouth_size      := ReactiveFloat.new(0, self)
@export var mouth_height    := ReactiveFloat.new(0, self)
@export var mouth_flattening:= ReactiveFloat.new(0, self)
@export var mouth_texture   := ReactiveTexture.new(default_texture, self)
#endregion

#region Head shape
@export_category("Head Shape")
@export var head_mesh       := ReactiveMesh.new(default_mesh, self)
#endregion

#region Skin
@export_category("Skin")
@export var skin_color      := ReactiveColor.new(Color(0.8, 0.6, 0.5), self)
#endregion
