extends Area2D
@export var interior_scene_path: String
var player_world_coordinates: Vector2 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _change_scene():
	get_tree().change_scene_to_file(interior_scene_path)
	pass
func _on_body_entered(body: Node2D) -> void:
	player_world_coordinates = body.global_position
	_change_scene()
	print("Entering door")
