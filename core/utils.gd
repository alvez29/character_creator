extends Node


func get_child_of_type_recursive(subject: Node, type):
	for child in subject.get_children():
		if is_instance_of(child, type):
			return child
		var result = child.get_child_of_type_recursive(type)
		if result:
			return result
	return null
