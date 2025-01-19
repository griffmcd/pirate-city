extends Node2D
class_name InputComponent
@export var movement_speed: float = 20.0
@export var velocity_component: VelocityComponent 
@export var animation_component: AnimationComponent
@export var character_body: CharacterBody2D

const LEFT_DIR = Vector2(-1, 0)
const RIGHT_DIR = Vector2(1, 0)
const UP_DIR = Vector2(0, -1)
const DOWN_DIR = Vector2(0, 1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	actor_setup.call_deferred()
	
func actor_setup() -> void:
	await get_tree().physics_frame
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("move_left"):
		velocity_component.accelerate(LEFT_DIR, delta)
	if Input.is_action_pressed("move_right"):
		velocity_component.accelerate(RIGHT_DIR, delta)
	if Input.is_action_pressed("move_up"):
		velocity_component.accelerate(UP_DIR, delta)
	if Input.is_action_pressed("move_down"):
		velocity_component.accelerate(DOWN_DIR, delta)
	animation_component.update_animation_based_on_pathfinding_velocity(velocity_component.velocity)
	velocity_component.move(character_body)
