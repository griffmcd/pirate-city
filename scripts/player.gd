extends CharacterBody2D

signal hit 
var direction = Vector2(1, 0)
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var SCREEN_SIZE
const LEFT_DIR = Vector2(-1, 0)
const RIGHT_DIR = Vector2(1, 0)
const UP_DIR = Vector2(0, -1)
const DOWN_DIR = Vector2(0, 1)

func _ready() -> void:
	SCREEN_SIZE = get_viewport_rect().size
	hide()
	
func start(pos):
	position = pos 
	show()
	$CollisionShape2D.disabled = false 
	
func _process(delta: float) -> void:
	var velocity = Vector2.ZERO
	var is_attacking = false 
	if Input.is_action_pressed("move_right"):
		direction = RIGHT_DIR
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		direction = LEFT_DIR
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		direction = DOWN_DIR
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		direction = UP_DIR 
		velocity.y -= 1
	if Input.is_action_pressed("attack"):
		is_attacking = true 
		
	if velocity.length() > 0:
		velocity = velocity.normalized() * SPEED 
		$AnimatedSprite2D.play()
	elif is_attacking:
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	position += velocity * delta 

	if is_attacking:
		if direction == RIGHT_DIR:
			$AnimatedSprite2D.animation = "attack_right"
		elif direction == LEFT_DIR:
			$AnimatedSprite2D.animation = "attack_left"
		elif direction == UP_DIR:
			$AnimatedSprite2D.animation = "attack_up"
		elif direction == DOWN_DIR:
			$AnimatedSprite2D.animation = "attack_down"
	elif velocity.x > 0:
		$AnimatedSprite2D.animation = "walk_right"
	elif velocity.x < 0:
		$AnimatedSprite2D.animation = "walk_left"
	elif velocity.y > 0:
		$AnimatedSprite2D.animation = "walk_down"
	elif velocity.y < 0:
		$AnimatedSprite2D.animation = "walk_up"


func _physics_process(delta):
	move_and_slide()
