extends CharacterBody2D

signal hit 
var direction = Vector2(1, 0)
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var SCREEN_SIZE

func _ready() -> void:
	SCREEN_SIZE = get_viewport_rect().size
	hide()
	
func start(pos):
	position = pos 
	show()
	$CollisionShape2D.disabled = false 
	
func _process(delta: float) -> void:
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		direction = Vector2(1, 0)
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		direction = Vector2(-1, 0)
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		direction = Vector2(0, 1)
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		direction = Vector2(0, -1)
		velocity.y -= 1
		
	if velocity.length() > 0:
		velocity = velocity.normalized() * SPEED 
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	position += velocity * delta 
	#position = position.clamp(Vector2.ZERO, SCREEN_SIZE:
	
	if velocity.x > 0:
		$AnimatedSprite2D.animation = "walk_right"
	elif velocity.x < 0:
		$AnimatedSprite2D.animation = "walk_left"
	elif velocity.y > 0:
		$AnimatedSprite2D.animation = "walk_down"
	elif velocity.y < 0: 
		$AnimatedSprite2D.animation = "walk_up"

func _physics_process(delta):    
	velocity = direction * SPEED
	move_and_slide()
