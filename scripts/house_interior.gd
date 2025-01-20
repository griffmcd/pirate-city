extends Node2D

@export var exterior_world: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_door_to_world_body_entered(body: Node2D) -> void:
	SceneSwitcher.switch_scene("res://scenes/world.tscn")
