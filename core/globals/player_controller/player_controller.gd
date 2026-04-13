extends Node

var possessed_pawn: Node = null
var _current_pawn_component: PawnComponent = null

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
	if event is InputEventMouseButton and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func possess(pawn: Node) -> void:
	unpossess_current()
	
	possessed_pawn = pawn
	
	if possessed_pawn:
		_current_pawn_component = _get_pawn_component(possessed_pawn)
		if _current_pawn_component:
			_current_pawn_component.possess()
		elif possessed_pawn.has_method("possess"):
			possessed_pawn.possess()


func unpossess_current() -> void:
	if _current_pawn_component:
		_current_pawn_component.unpossess()
	elif possessed_pawn and possessed_pawn.has_method("unpossess"):
		possessed_pawn.unpossess()
		
	possessed_pawn = null
	_current_pawn_component = null


func _get_pawn_component(node: Node) -> PawnComponent:
	if node is PawnComponent:
		return node
		
	for child in node.get_children():
		var result = _get_pawn_component(child)
		if result != null:
			return result
	
	return null
