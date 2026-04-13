## This node is separated from the 3D node to be rendered in the base desired resolution and not subviewport 3d scale override
extends Control

@export
var player: Player
@onready
var aimer: Aimer = %Aimer

@onready
var debug_info: DebugInfo = %DebugInfo
