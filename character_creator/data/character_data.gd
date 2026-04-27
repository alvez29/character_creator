class_name CharacterData
extends Reactive

var skin_color := ReactiveColor.new(Color(0.8, 0.6, 0.5), self)

## values parameters
@export_category("Eyes")
@export var eyes_size := ReactiveFloat.new(0, self)
@export var eyes_separation := ReactiveFloat.new(0, self)
@export var eyes_rotation := ReactiveFloat.new(0, self)
@export var eyes_height := ReactiveFloat.new(0, self)

## style parameters
@export var eye_texture := ReactiveTexture.new(null, self)
