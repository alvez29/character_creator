## Root control node for the UI Heads-Up Display rendering the crosshair and debug info elements.
extends Control

@export
var player: Player
@onready
var aimer: Aimer = %Aimer

@onready
var debug_info: DebugInfo = %DebugInfo
