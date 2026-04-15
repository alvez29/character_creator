## Tool script providing a custom 3D squared shape with dynamic visual dimensions and physics collision bindings.
@tool
extends StaticBody3D

@onready var collision_shape = %SquaredCollisionShape
@onready var mesh_instance = %SquaredMeshInstance3D

@export var material: Material
@export_flags_3d_physics var mesh_collision_layer: int = 2
@export_flags_3d_physics var mesh_collision_mask: int = (1 << 0) | (1 << 2) | (1 << 3)

@export var dimensions = Vector3(1, 1, 1):
	set(value):
		dimensions = value
		if collision_shape and collision_shape.shape:
			collision_shape.shape.size = value
		if mesh_instance and mesh_instance.mesh:
			mesh_instance.mesh.size = value

func _ready() -> void:
	var box_shape = BoxShape3D.new()
	var box_mesh = BoxMesh.new()
	
	box_shape.size = dimensions
	box_mesh.size = dimensions
	box_mesh.material = material

	collision_layer = mesh_collision_layer
	collision_mask = mesh_collision_mask
	
	collision_shape.shape = box_shape
	mesh_instance.mesh = box_mesh
