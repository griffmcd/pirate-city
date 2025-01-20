extends Node

var coins = 0
@onready var coin_label: Label = %CoinLabel

func increase_coin_amount(new_coins: int) -> void:
	coins += new_coins
	coin_label.text = "  :" + str(coins)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
