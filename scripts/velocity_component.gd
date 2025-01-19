extends Node
class_name VelocityComponent
# TODO: implement functions to calculate these 
signal stopped 
signal at_max_speed 
# TODO: Should we keep track of old velocity and signal changes from here?
@export var max_speed = 100.0
@export var acceleration = 1000.0
@export var deceleration = 100.0
@export var velocity: Vector2
@export var friction = 500.0
@export var debug_mode = true 

const LEFT_DIR = Vector2(-1, 0)
const RIGHT_DIR = Vector2(1, 0)
const UP_DIR = Vector2(0, -1)
const DOWN_DIR = Vector2(0, 1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	decelerate(delta)
	
func accelerate(new_velocity, delta):
	velocity = velocity.move_toward(new_velocity * max_speed, acceleration * delta)
	
func decelerate(delta):
	velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
	
func move(body: CharacterBody2D):
	body.velocity = velocity
	body.move_and_slide()
	
