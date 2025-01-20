extends Node
class_name GameStateHelper

signal loading_data(data)
signal saving_data(data)

const NODE_GROUP = "GameStateHelper"
# parent node path 
const GAME_STATE_KEY_NODE_PATH = "game_state_helper_node_path"
# path to scene file so dynamically instanced nodes can be re-instanced
const GAME_STATE_KEY_INSTANCE_SCENE = "game_state_helper_dynamic_recreate_scene"
# flag indicating that an instanced child scene was freed so that it can be 
# re-freed when scene re-loaded
const GAME_STATE_KEY_PARENT_FREED = "game_state_helper_parent_freed"

class saveFreedInstanceChildScene:
	var id: String
	var node_path: String 
	func _init(save_id: String, save_node_path: String) -> void:
		id = save_id
		node_path = save_node_path 
	func save_data(data: Dictionary) -> void:
		var node_data := {}
		# add node data to data dictionary 
		data[id] = node_data 
		node_data[GAME_STATE_KEY_PARENT_FREED] = true
		node_data[GAME_STATE_KEY_NODE_PATH] = node_path 
		
@export var save_properties: Array[String] = []
@export var dynamic_instance := false: set = _set_dynamic_instance
@export var global := false: set = _set_global
@export var debug := false 

func _set_dynamic_instance(value: bool) -> void:
	if global and value:
		printerr("GameStateHelper: Dynamic Instance and Global cannot both be true.")
		return
	dynamic_instance = value 
	
func _set_global(value: bool) -> void:
	if dynamic_instance and value:
		printerr("GameStateHelper: Dynamic Instance and Global cannot both be true.")
		return
	global = value 
	
func _enter_tree():
	add_to_group(NODE_GROUP)
	if has_user_signal("instanced_child_scene_freed"):
		return
	# signal to let service know an instanced child scene was freed. 
	# add this signal this way hides it in the signals panel - it's only meant for the service
	add_user_signal("instanced_child_scene_freed", [
		{
			"save_freeds_instanced_child_scene_object": TYPE_OBJECT
		}
	])
	
func save_data(data: Dictionary) -> void:
	var parent = get_parent()
	var id = str(parent.get_path())
	var node_data := {}
	if global:
		node_data = data
	else:
		data[id] = node_data 
	
	if !parent.owner and !global and parent != get_tree().current_scene:
		# no owner means the parent was instanced. Save the scene file path so 
		# it can be re-instanced.
		node_data[GAME_STATE_KEY_INSTANCE_SCENE] = parent.scene_file_path 
	# save path - makes data easier to identify in save file for debugging 
	# also used to find parent to instanced scenes 
	if !global:
		node_data[GAME_STATE_KEY_NODE_PATH] = parent.get_path()
		
	# add property to node data 
	for property_name in save_properties:
		node_data[property_name] = parent.get_indexed(property_name)
		
	emit_signal("saving_data", node_data)
	
func load_data(data: Dictionary) -> void:
	var parent = get_parent()
	var id = str(parent.get_path())
	
	var node_data: Dictionary 
	
	if global:
		node_data = data 
	elif data.has(id):
		node_data = data[id]
	else:
		emit_signal("loading_data", node_data)
		return
	
	# if parent was noted as being freed in the save file, free it again
	if node_data.has(GAME_STATE_KEY_PARENT_FREED):
		if node_data[GAME_STATE_KEY_PARENT_FREED]:
			parent.queue_free()
			return
	
	# set parent property values
	for prop_name in save_properties:
		if node_data.has(prop_name):
			parent.set_indexed(prop_name, node_data[prop_name])
	
	emit_signal("loading_data", node_data)
	
func set_data(node_data: Dictionary) -> void:
	var parent = get_parent()
	for prop_name in save_properties:
		parent.set(prop_name, node_data[prop_name])
	emit_signal("loading_data", node_data)
	
func _exit_tree():
	if dynamic_instance:
		return
	var parent = get_parent()
	var id = str(parent.get_path())
	var save_freed_object = saveFreedInstanceChildScene.new(id, parent.get_path())
	emit_signal("instanced_child_scene_freed", save_freed_object)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
