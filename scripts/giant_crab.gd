extends Node2D

const SPEED = 200
const LEFT_DIR = Vector2i(-1, 0)
const RIGHT_DIR = Vector2i(1, 0)
const UP_DIR = Vector2i(0, -1)
const DOWN_DIR = Vector2i(0, 1)

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_up: RayCast2D = $RayCastUp
@onready var ray_cast_down: RayCast2D = $RayCastDown

var direction = Vector2(-1, 0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.animation = "crab_left"
	pass # Replace with function body.

func get_animation_for_direction(velocity: Vector2) -> String:
	if velocity.x == -1:	
		return "crab_left"
	elif velocity.x == 1:
		return "crab_right"
	elif velocity.y == -1:
		return "crab_up"
	elif velocity.y == 1:
		return "crab_down"
	return "crab_left"
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var should_switch_direction = true if randf_range(0, 1) > 0.99 else false 
	if ray_cast_right.is_colliding():
		direction.x = -1
		$AnimatedSprite2D.animation = "crab_left"
	if ray_cast_left.is_colliding():
		direction.x = 1 
		$AnimatedSprite2D.animation = "crab_right"
	if ray_cast_up.is_colliding():
		direction.y = 1
		$AnimatedSprite2D.animation = "crab_down"
	if ray_cast_down.is_colliding():
		direction.y = -1 
		$AnimatedSprite2D.animation = "crab_up"
	if should_switch_direction:
		var x = pow(-1, randi() % 2)
		var y = pow(-1, randi() % 2)
		direction = Vector2(x, y)
		$AnimatedSprite2D.animation = get_animation_for_direction(direction)
	if direction.length() > 0:
		direction = direction.normalized()
	position.x += direction.x * SPEED * delta 
	position.y += direction.y * SPEED * delta 
	
func damage() -> void:
	print('damaged crab')
	queue_free()
