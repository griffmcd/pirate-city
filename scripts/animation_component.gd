extends Node2D
class_name AnimationComponent 

@export var animated_sprite: AnimatedSprite2D
const MOVE_LEFT: String = "move_left"
const MOVE_RIGHT: String = "move_right"
const MOVE_UP: String = "move_up"
const MOVE_DOWN: String = "move_down"

func update_animation_based_on_velocity(velocity: Vector2) -> void:
	if velocity.x > 0.2 or velocity.y > 0.2:
		if abs(velocity.x) > abs(velocity.y):
			if velocity.x < 0:
				animated_sprite.animation = MOVE_LEFT
			elif velocity.x > 0:
				animated_sprite.animation = MOVE_RIGHT
		else:
			if velocity.y < 0:
				animated_sprite.animation = MOVE_UP
			elif velocity.y > 0: 
				animated_sprite.animation = MOVE_DOWN
		animated_sprite.play()
	else:
		animated_sprite.stop()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
