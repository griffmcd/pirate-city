extends CharacterBody2D

@export var pathfind_target: Node2D
var last_target_position: Vector2 

func _ready() -> void:
	update_pathfind_target_position()

func update_pathfind_target_position():
	get_node("PathfindComponent").target_position = pathfind_target.global_position
	
func _process(delta: float) -> void:
	update_pathfind_target_position()
	
func _physics_process(delta: float) -> void:
	pass
