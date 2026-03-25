class_name Grabbable
extends RigidBody3D

func grab():
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	can_sleep = false

func release():
	can_sleep = true
