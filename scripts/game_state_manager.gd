extends Node

signal state_load_completed()
signal new_game_state_initialized()

var _game_state_default := {
	"meta_data": {
		"current_scene_path": ""
	},
	"global": {},
	"scene_data": {},
}
var _game_state := {
	"meta_data": {
		"current_scene_path": ""
	},
	"global": {},
	"scene_data": {},
}

# list of scene resources that have already been loaded 
var loaded_scene_resources := {}
# list of object with data about instanced child scenes that have been freed
var _freed_instanced_scene_save_and_loads = []
# used when save game is loaded. Prevents current scene game state from being saved 
# before changing scene 
var _skip_next_scene_transition_save := false 
var coins = 0
@onready var coin_label: Label = %CoinLabel

func increase_coin_amount(new_coins: int) -> void:
	coins += new_coins
	coin_label.text = "  :" + str(coins)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await GameStateManager.state_load_completed
	# monitor whenever a node is added to the tree--we can tell when a new scene
	# is loaded this way
	if OK != get_tree().connect("node_added", Callable(self, "_on_scene_tree_node_added")):
		printerr("GameStateManager: could not connect to scene tree node_added signal")
	
	var current_scene = get_tree().current_scene
	if current_scene != null:
		_on_scene_tree_node_added(current_scene)
	
	var transition_mgr = get_tree().root.get_node_or_null("TransitionMgr")
	if transition_mgr == null:
		return
	transition_mgr.connect("scene_transitioning", _on_scene_transitioning)
	# OLD STUFF BELOW 
	var root = get_tree().root 
	current_scene = root.get_child(-1)

func dump_game_state() -> void:
	var file_name = "user://game_state_dump_%s.json" % _get_time_date_string()
	var json_string = JSON.stringify(_game_state, "\t")
	var file = FileAccess.open(file_name, FileAccess.WRITE)
	file.store_string(json_string)
	
	
func get_game_state_string(refresh_state: bool = false) -> String:
	if refresh_state:
		# fake scene transition to force game update 
		_on_scene_transitioning("")
	return JSON.stringify(_game_state, "\t")
	
func get_global_state_value(key: String):
	var global_state = _game_state["global"]
	if global_state.has(key):
		return global_state[key]
	return null
	
func load_game_state(path: String, scene_transition_func: Callable) -> bool:
	if !FileAccess.file_exists(path):
		printerr("GameStateManager: File does not exist: path %s" % path)
		return false 
	
	var save_file_hash = _get_file_content_hash(path)
	var saved_hash = _get_save_file_hash(path)
	
	if save_file_hash != saved_hash:
		printerr("GameStateManager: Save file is corrupt or has been modified: path %s" % path)
		return false
		
	var file = FileAccess.open(path, FileAccess.READ)
	
	if file == null or !file.is_open():
		printerr("GameStateManager: File does not exist: path %s" %path)
		
	_game_state = str_to_var(file.get_as_text())
	file.close()
	_skip_next_scene_transition_save = true 
	# return path to scene that was current for save file 
	# This lets the caller handle the transition.
	var scene_path = _game_state["meta_data"]["current_scene_path"]
	if scene_transition_func != null:
		scene_transition_func.call(scene_path)
	return true 

func new_game() -> void:
	_game_state = _game_state_default.duplicate(true)
	new_game_state_initialized.emit()
	
	
func save_game_state(path: String) -> bool:
	# fake a scene transition to force game state to be updated 
	_on_scene_transitioning("")
	
	_game_state["game_data_version"] = "1.0"
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null or !file.is_open():
		printerr("GameStateManager: Couldn't open file to save to: path %s" % path)
		return false 
	file.store_string(var_to_str(_game_state))
	file.close()
	return true 
	
func set_global_state_value(key: String, value) -> void:
	var global_state = _game_state["global"]
	global_state[key] = value
	
func _on_scene_tree_node_added(node: Node) -> void:
	if node != get_tree().current_scene:
		return 
	_handle_scene_load(node)


func _get_scene_id(node: Node) -> String:
	var id = node.get("id")
	if id == null:
		if node.scene_file_path != null:
			id = node.scene_file_path
		else:
			printerr("GameStateManager: scene has no scene file path: %s" % node.get_path())
	return id
	
func _get_scene_data(id: String, node: Node) -> Dictionary:
	var scene_data: Dictionary = _game_state["scene_data"]
	if !scene_data.has(id):
		var temp = {
			"scene_file_path": node.scene_file_path,
			"node_data": {}
		}
		scene_data[id] = temp
	return scene_data
	
func _handle_scene_load(node: Node) -> void:
	# array was populated when old scene unloaded - these are not legit free 
	# instances 
	_freed_instanced_scene_save_and_loads.clear()
	
	var scene_id: String = _get_scene_id(node)
	if scene_id.is_empty():
		return
	
	# store path to scene file for the now current scene
	_game_state["metadata"]["current_scene_path"] = node.scene_file_path
	
	await node. ready 
	
	# connect to helper node freed signal - for handling instanced child scenes 
	# that are freed at runtime 
	_connect_to_GameStateHelper_freed_signal()
	
	var scene_data = _get_scene_data(scene_id, node)
	var node_data = scene_data["node_data"]
	var global_state = _game_state["global"]
	
	# load data into each helper node 
	for temp in get_tree().get_node_in_group(GameStateHelper.NODE_GROUP):
		var helper: GameStateHelper = temp 
		if helper.debug:
			breakpoint
		if helper.global:
			helper.load_data(global_state)
		else:
			helper.load_data(node_data)
			
	# recreate dynamically instanced nodes 
	load_dynamic_instanced_nodes(node_data)
	emit_signal("state_load_completed")
	
func load_dynamic_instanced_nodes(data: Dictionary) -> void:
	var dynamic_instanced_node_ids := []
	
	for id in data.keys():
		if typeof(data[id]) != TYPE_DICTIONARY:
			continue
		var node_data: Dictionary = data[id]
		if !node_data.has(GameStateHelper.GAME_STATE_KEY_INSTANCE_SCENE):
			continue
		if !node_data.has(GameStateHelper.GAME_STATE_KEY_NODE_PATH):
			continue
		var parent = _get_parent(node_data[GameStateHelper.GAME_STATE_KEY_NODE_PATH])
		if parent == null:
			printerr("GameStateManager: could not get parent for dynamic instanced node: %s" % node_data[GameStateHelper.GAME_STATE_KEY_NODE_PATH])
		dynamic_instanced_node_ids.append(id)
		_instance_scene(parent, node_data, id)
		
	for id in dynamic_instanced_node_ids:
		data.erase(id)
		
func _get_parent(child_node_path: String) -> Node:
	var parent_path = child_node_path.get_base_dir()
	var parent = get_tree().root.get_node_or_null(parent_path)
	return parent 
	
func _get_scene_resource(resource_path: String) -> PackedScene:
	if loaded_scene_resources.has(resource_path):
		return loaded_scene_resources[resource_path]
	var resource = load(resource_path)
	if resource == null:
		printerr("GameStateManager: Could not load scene resource: %s" % resource_path)
	loaded_scene_resources[resource_path] = resource 
	return resource 
	
func _instance_scene(parent: Node, node_data: Dictionary, id: String) -> void:
	var resource := _get_scene_resource(node_data[GameStateManager.GAME_STATE_KEY_INSTANCE_SCENE])
	if resource == null:
		printerr("GameStatemanager: Could not instance node: resource not found. Save file id: %s, scene path: %s" % [id, node_data[GameStateHelper.GAME_STATE_KEY_INSTANCE_SCENE]])
		return 
	var instance = resource.instantiate()
	parent.add_child(instance)
	var game_state_helper = _get_game_state_helper(instance)
	if game_state_helper != null:
		if game_state_helper.debug:
			breakpoint
		game_state_helper.set_data(node_data)
	else:
		parent.remove_child(instance)
		printerr("GameStateManager: Instanced node has no GameStateHelper node: Save file id: %s, scene path: %s" % [id, node_data[GameStateHelper.GAME_STATE_KEY_INSTANCE_SCENE]])
	
func _get_game_state_helper(parent: Node):
	for child in parent.get_children():
		if child.is_in_group(GameStateHelper.NODE_GROUP):
			return child
	return null 
	
func _connect_to_GameStateHelper_freed_signal():
	for save_and_load in get_tree().get_nodes_in_group(GameStateHelper.NODE_GROUP):
		if !save_and_load.is_connected("instanced_child_scene_freed", Callable(self, "_on_instanced_child_scene_freed")):
			save_and_load.connect("instanced_child_scene_freed", Callable(self, "_on_instanced_child_scene_freed"))
		

func _on_instanced_child_scene_freed(data: Dictionary) -> void: 
	for save_and_load in _freed_instanced_scene_save_and_loads:
		save_and_load.save_data(data)
	_freed_instanced_scene_save_and_loads.clear()
	
func _save_freed_save_and_load(data: Dictionary) -> void:
	for save_and_load in _freed_instanced_scene_save_and_loads:
		save_and_load.save_data(data)
	_freed_instanced_scene_save_and_loads.clear()
	
func _on_scene_transitioning(_new_scene_path) -> void:
	# skip transition when loading a saved game
	if _skip_next_scene_transition_save:
		_skip_next_scene_transition_save = false
		return
	var current_scene: Node = get_tree().current_scene
	var scene_id: String = _get_scene_id(current_scene)
	if scene_id.is_empty():
		return
	
	var scene_data = _get_scene_data(scene_id, current_scene)
	var node_data = scene_data["node_data"]
	var global_state = _game_state["global"]
	
	for n in get_tree().get_nodes_in_group(GameStateHelper.NODE_GROUP):
		if n.debug:
			breakpoint
		if n.global:
			n.save_data(global_state)
		else:
			n.save_data(node_data)
			
	# save data about freed instance child scenes 
	_save_freed_save_and_load(node_data)
	
func _get_time_date_string():
	# year, month, day, weekday, dst (daylight savings time), hour, minute, second.
	var datetime = Time.get_datetime_dict_from_system()
	return "%d%02d%02d_%02d%02d%02d" % [datetime["year"], datetime["month"], datetime["day"], datetime["hour"], datetime["minute"], datetime["second"]]

func _get_file_content_hash(file_path: String) -> String:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null or !file.is_open():
		return ""
	var content = file.get_as_text()
	file.close()
	return content.md5_text()
	
func _get_save_file_hash(file_path: String) -> String:
	file_path = file_path.replace("." + file_path.get_extension(), ".dat")
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null or !file.is_open():
		return ""
	var content = file.get_as_text()
	file.close()
	return content.md5_text()
	
func _save_save_file_hash(file_path: String) -> void:
	var content_hash = _get_file_content_hash(file_path)
	file_path = file_path.replace("." + file_path.get_extension(), ".dat")
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null or !file.is_open():
		return
	file.store_string(content_hash)
	file.close()
	

func goto_scene(path):
	# this function will usually be called from a signal callback,
	# or some other function in the current scene.
	_deferred_goto_scene.call_deferred(path)
	
func _deferred_goto_scene(path):
	#current_scene.free()
	#var new_scene = ResourceLoader.load(path)
	#current_scene = new_scene.instantiate()
	#get_tree().root.add_child(current_scene)
	#get_tree().current_scene = current_scene
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
