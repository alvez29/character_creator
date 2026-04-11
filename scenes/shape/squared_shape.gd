@tool
extends StaticBody3D

@onready var collision_shape = %SquaredCollisionShape
@onready var mesh_instance = %SquaredMeshInstance3D

@export var dimensions = Vector3(1, 1, 1):
	set(value):
		if collision_shape:
			collision_shape.shape.size = value
		if mesh_instance:
			mesh_instance.mesh.size = value
		dimensions = value

func _ready() -> void:
	var box_shape: Shape3D = BoxShape3D.new()
	var box_mesh: BoxMesh = BoxMesh.new()
	
	box_shape.size = Vector3(1, 1, 1)
	box_mesh.size = Vector3(1, 1, 1)
	
	collision_shape = box_shape
	mesh_instance.mesh = box_mesh
