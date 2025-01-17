extends Node2D
class_name InputComponent

@export var velocity_component: VelocityComponent 
@export var animated_sprite: AnimatedSprite2D
@export var character_body: CharacterBody2D
@export var direction: Vector2
@export var animation: String

const LEFT_DIR = Vector2(-1, 0)
const RIGHT_DIR = Vector2(1, 0)
const UP_DIR = Vector2(0, -1)
const DOWN_DIR = Vector2(0, 1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	direction = velocity_component.velocity
	if direction == LEFT_DIR:
		animated_sprite.animation = "move_left"
	elif direction == RIGHT_DIR:
		animated_sprite.animation = "move_right"
	elif direction == UP_DIR:
		animated_sprite.animation = "move_up"
	else:
		animated_sprite.animation = "move_down"
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("move_left"):
		velocity_component.accelerate(LEFT_DIR, delta)
		animated_sprite.animation = "move_left"
	if Input.is_action_pressed("move_right"):
		velocity_component.accelerate(RIGHT_DIR, delta)
		animated_sprite.animation = "move_right"
	if Input.is_action_pressed("move_up"):
		velocity_component.accelerate(UP_DIR, delta)
		animated_sprite.animation = "move_up"
	if Input.is_action_pressed("move_down"):
		velocity_component.accelerate(DOWN_DIR, delta)
		animated_sprite.animation = "move_down"
	if velocity_component.velocity.length() > 0:
		animated_sprite.play()
	else:
		animated_sprite.stop()
	velocity_component.move(character_body)
