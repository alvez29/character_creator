class_name ShakeProfile
extends Resource
## A configuration resource defining the properties of a shake event.

enum ShakeType { 
	SMOOTH, ## Uses noise for a smooth, continuous camera-like shake.
	SNAP    ## Uses purely random offsets without smoothing. Perfect for Smash Bros character hit reactions.
}

@export var shake_type: ShakeType = ShakeType.SMOOTH

@export_group("Amplitude (Translation)")
@export var amplitude_x: float = 0.1
@export var amplitude_y: float = 0.1
@export var amplitude_z: float = 0.1

@export_group("Amplitude (Rotation - Degrees)")
@export var rotation_x: float = 5.0
@export var rotation_y: float = 5.0
@export var rotation_z: float = 5.0

@export_group("Behavior")
## How fast the noise moves or how often the snap updates. Higher is faster shaking.
@export var frequency: float = 15.0
## Duration of the shake in seconds when using add_trauma().
@export var duration: float = 1.0

@export_group("Tween Settings")
@export var transition_type: Tween.TransitionType = Tween.TRANS_SINE
@export var ease_type: Tween.EaseType = Tween.EASE_OUT
