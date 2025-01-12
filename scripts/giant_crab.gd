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

var direction = LEFT_DIR 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.animation = "crab_left"
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
	position.x += direction.x * SPEED * delta 
	position.y += direction.y * SPEED * delta 
