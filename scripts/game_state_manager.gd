extends Node

var coins = 0
@onready var coin_label: Label = %CoinLabel
var current_scene = null 

func increase_coin_amount(new_coins: int) -> void:
	coins += new_coins
	coin_label.text = "  :" + str(coins)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var root = get_tree().root 
	current_scene = root.get_child(-1)

func goto_scene(path):
	# this function will usually be called from a signal callback,
	# or some other function in the current scene.
	_deferred_goto_scene.call_deferred(path)
	
func _deferred_goto_scene(path):
	current_scene.free()
	var new_scene = ResourceLoader.load(path)
	current_scene = new_scene.instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
