extends Node

class_name MovementComponent 

@export var actor: CharacterBody2D
@export var min_slide_angle = 0.0
@export var animated_sprite: AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	actor.wall_min_slide_angle = min_slide_angle
	actor.motion_mode = actor.MOTION_MODE_FLOATING


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	actor.move_and_slide()
