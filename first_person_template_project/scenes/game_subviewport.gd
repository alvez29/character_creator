class_name GameSubviewport
extends SubViewport

func _ready() -> void:
	## Setting the 3D scale for visual appearance
	scaling_3d_scale = SettingsManager.get_setting("viewport_scale_3d")
	
	## In most cases, we need this viewport to handle inputs globally
	handle_input_locally = false
