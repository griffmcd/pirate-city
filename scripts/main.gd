extends Node2D

func game_over():
	pass
	
func new_game():
	$Player.start($Player/StartPosition.position)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
