extends Node2D
class_name HealthComponent 

signal health_changed
signal died

@export var max_health = 100
@export var current_health = max_health

func get_max_health():
	return max_health 
	
func set_max_health(new_max_health):
	max_health = new_max_health 
	
func heal(amount):
	if current_health + amount > max_health:
		current_health = max_health
	else:
		current_health += amount
	health_changed.emit(current_health)
	
	
func damage(amount):
	current_health -= amount 
	if current_health < 0:
		died.emit()
	
func get_health():
	return current_health 
	
func set_health(new_health):
	current_health = new_health 
	health_changed.emit(current_health)
	if current_health < 0:
		died.emit()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
