extends Node2D
class_name PathfindComponent
@export var movement_speed: float = 10.0
@export var velocity_component: VelocityComponent
@export var animation_component: AnimationComponent
@export var character_body: CharacterBody2D
@export var target_position: Vector2
@export var collision_radius: int = 0
var last_target_position: Vector2 = Vector2.ZERO
@export var path_desired_distance: float = 20.0
@export var target_desired_distance: float = 20.0
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# These values need to be adjusted for actor's speed 
	# and navigation layout 
	navigation_agent.path_desired_distance = path_desired_distance
	navigation_agent.target_desired_distance = target_desired_distance 
	actor_setup.call_deferred()
	
func actor_setup() -> void:
	# wait for first physics frame so NavigationServer can sync 
	await get_tree().physics_frame
	set_movement_target(target_position)
	last_target_position = target_position 
	var velocity = global_position.direction_to(target_position) * movement_speed
	animation_component.update_animation_based_on_pathfinding_velocity(velocity)
	
func set_movement_target(movement_target: Vector2):
	navigation_agent.set_target_position(movement_target)
	
func is_within_collision_radius() -> bool:
	var offset = Vector2(collision_radius, 0).rotated(navigation_agent.radius * PI / 2)
	return target_position.distance_to(global_position + offset) <= collision_radius
	
func _process(delta: float) -> void:
	if (target_position != last_target_position):
		set_movement_target(target_position)
	
	
func _physics_process(delta: float) -> void:
	if navigation_agent.is_navigation_finished():
		velocity_component.velocity = Vector2.ZERO
		return
	if navigation_agent.is_target_reached() or is_within_collision_radius():
		velocity_component.velocity = Vector2.ZERO
		return
	var current_agent_position: Vector2 = global_position 
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	animation_component.update_animation_based_on_pathfinding_velocity(velocity)
	velocity_component.accelerate(velocity, delta)
	velocity_component.move(character_body)
