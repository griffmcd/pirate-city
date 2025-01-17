extends Node2D
class_name PathfindComponent

@export var velocity_component: VelocityComponent
@export var animated_sprite: AnimatedSprite2D 
@export var character_body: CharacterBody2D
@export var target: Node2D
@export var debug_draw_enabled = true 
@export var movement_speed = 4.0
@export var navigation_agent: NavigationAgent2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	navigation_agent = $NavigationAgent2D
	var agent: RID = navigation_agent.get_rid()
	NavigationServer2D.agent_set_avoidance_enabled(agent, true)
	NavigationServer2D.agent_set_avoidance_callback(agent, Callable(self, "_avoidance_done"))
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	navigation_agent.target_position = Vector2.ZERO
	
func set_movement_target(movement_target: Vector2):
	navigation_agent.set_target_position(movement_target)
	
func _physics_process(delta: float) -> void:
	# do not query when the map has never synchronized and is empty 
	if NavigationServer2D.map_get_iteration_id(navigation_agent.get_navigation_map()):
		print("1")
		return
	if navigation_agent.is_navigation_finished():
		print("2")
		return
	print('f')
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var new_velocity: Vector2 = global_position.direction_to(next_path_position) * movement_speed
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity_forced(new_velocity)
	else:
		_on_velocity_computed(new_velocity, delta)
		
func _on_velocity_computed(safe_velocity: Vector2, delta: float): 
	velocity_component.accelerate(safe_velocity, delta)
	velocity_component.move(character_body)
	var final_position = navigation_agent.get_final_position()
	print(final_position)
	character_body.move_and_slide()
	
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
