## Setting for float parameters that map discrete slider steps to float values.
## Configure min_value, max_value and steps in the inspector (.tres).
## For rotation parameters, enable use_degrees so the inspector values are
## human-readable degrees while the equivalence map stores radians.
class_name RangeSetting
extends CharacterSetting

@export var steps: int = 10
@export var min_value: float = 0.0
@export var max_value: float = 1.0
## When true, min_value/max_value are degrees; get_value() returns radians.
@export var use_degrees: bool = false

## Built at runtime by load(). Maps slider step index → float value.
var equivalence: Dictionary[int, float]


func load() -> void:
	equivalence.clear()
	var from := deg_to_rad(min_value) if use_degrees else min_value
	var to   := deg_to_rad(max_value) if use_degrees else max_value
	
	for i in range(steps):
		var t := float(i) / (steps - 1) if steps > 1 else 0.0
		equivalence[i] = snapped(lerp(from, to, t), 0.01)


## Returns the float value for a given slider step index.
func get_value(step: int) -> float:
	return equivalence.get(step, min_value)
