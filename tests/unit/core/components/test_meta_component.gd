extends GutTest

class DummyMetaComponent extends MetaComponent:
	func get_related_meta() -> StringName:
		return &"dummy_meta"

var meta_comp: DummyMetaComponent
var target: Node

func before_each():
	target = Node.new()
	add_child(target)
	
	meta_comp = DummyMetaComponent.new()
	meta_comp.target_body = target

func after_each():
	if is_instance_valid(meta_comp):
		meta_comp.free()
	if is_instance_valid(target):
		target.free()

func test_meta_set_on_ready():
	assert_false(target.has_meta("dummy_meta"), "Target should not have meta before ready")
	
	add_child(meta_comp) # Triggers _ready()
	
	assert_true(target.has_meta("dummy_meta"), "Target should have meta after ready")
	assert_eq(target.get_meta("dummy_meta"), meta_comp, "Meta should be the component itself")

func test_meta_removed_on_exit_tree():
	add_child(meta_comp)
	assert_true(target.has_meta("dummy_meta"))
	
	remove_child(meta_comp) # Triggers _exit_tree()
	
	assert_false(target.has_meta("dummy_meta"), "Target should no longer have meta after exit_tree")
