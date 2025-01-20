extends Node

var current_scene = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	print_debug(current_scene)
	
func switch_scene(resource_path) -> void:
	call_deferred("_deferred_switch_scene", resource_path)
	
func _deferred_switch_scene(resource_path) -> void:
	current_scene.free()
	var new_scene = load(resource_path)
	current_scene = new_scene.instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene
