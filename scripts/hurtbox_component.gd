extends Area2D

signal hit_by_projectile
signal hit_by_hitbox 

@export var health_component: HealthComponent
@export var status_receiver: Node 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func deal_damage(amount):
	health_component.damage(amount)
	
func _on_projectile_collision():
	hit_by_projectile.emit()

func _on_hitbox_collision():
	hit_by_hitbox.emit()
