extends Node2D
class_name PathfindComponent

@export var velocity_component: VelocityComponent
@export var animated_sprite: AnimatedSprite2D 
@export var character_body: CharacterBody2D
@export var target: Node2D
@export var debug_draw_enabled = true 
@export var movement_speed = 4.0
@onready var navigation_agent: NavigationAgent2D = get_node("NavAgent2D")
var movement_delta: float 


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var agent: RID = navigation_agent.get_rid()
	NavigationServer2D.agent_set_avoidance_enabled(agent, true)
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	set_movement_target(Vector2(100, 100))
	
func set_movement_target(movement_target: Vector2):
	navigation_agent.set_target_position(movement_target)
	
func _physics_process(delta: float) -> void:
	# do not query when the map has never synchronized and is empty 
	if NavigationServer2D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		print("f")
		return
	if navigation_agent.is_navigation_finished():
		print("G")
		return
	movement_delta = movement_speed * delta 
	print("movement_delta: " + str(movement_delta))
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	print("Next path position: " + str(next_path_position))
	print(global_position)
	var new_velocity: Vector2 = global_position.direction_to(next_path_position) * movement_delta 
	print("New velocity: " + str(new_velocity))
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
		print("Avoidance enabled, setting velocity: " + str(new_velocity))
	else:
		print("Entering on_velocity_computed with velocity: " + str(new_velocity) + " and delta: " + str(delta))
		_on_velocity_computed(new_velocity, delta)
		
func _on_velocity_computed(safe_velocity: Vector2, delta: float): 
	velocity_component.accelerate(safe_velocity, delta)
	velocity_component.move(character_body)
	var final_position = navigation_agent.get_final_position()
	print("Final position: " + str(final_position))
	character_body.move_and_slide()
	
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
