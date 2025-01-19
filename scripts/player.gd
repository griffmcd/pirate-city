extends CharacterBody2D

signal hit 

const SPEED = 300.0
const LEFT_DIR = Vector2(-1, 0)
const RIGHT_DIR = Vector2(1, 0)
const UP_DIR = Vector2(0, -1)
const DOWN_DIR = Vector2(0, 1)

@onready var attack_left_hitbox: RayCast2D = $Hitboxes/AttackLeftHitbox
@onready var attack_right_hitbox: RayCast2D = $Hitboxes/AttackRightHitbox
@onready var attack_down_hitbox: RayCast2D = $Hitboxes/AttackDownHitbox
@onready var attack_up_hitbox: RayCast2D = $Hitboxes/AttackUpHitbox
@onready var attack_cooldown_timer: Timer = $Hitboxes/AttackCooldownTimer

var direction = DOWN_DIR
var current_hitbox = attack_down_hitbox 
var can_attack = true 
var is_attacking = false 


func _ready() -> void:
	hide()
	
func start(pos):
	position = pos 
	show()
	$CollisionShape2D.disabled = false 
	
func _process(delta: float) -> void:
	if $AnimatedSprite2D.is_playing() && $AnimatedSprite2D.animation == "attack":
		return 
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		direction = RIGHT_DIR
		current_hitbox = attack_right_hitbox
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		direction = LEFT_DIR
		current_hitbox = attack_left_hitbox
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		direction = DOWN_DIR
		current_hitbox = attack_down_hitbox 
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		direction = UP_DIR 
		current_hitbox = attack_up_hitbox
		velocity.y -= 1
	if Input.is_action_pressed("attack") and can_attack:
		is_attacking = true 
		attack_cooldown_timer.start()

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
	if current_hitbox and current_hitbox.is_colliding():
		print('HIT')
		var collider = current_hitbox.get_collider()
		print(collider.get_class())
		if collider.has_method('damage'):
			collider.damage()
	move_and_slide()

func _on_attack_cooldown_timer_timeout() -> void:
	can_attack = true 
	is_attacking = false 
