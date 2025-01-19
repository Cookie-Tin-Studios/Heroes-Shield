extends RigidBody2D

@export var mob_health: float = 100  # Mob's maximum possible health
var health: float = mob_health       # Current health is initialized to maximum

func take_damage(damage: float):
	# Reduce health but ensure it doesn't go below 0
	health = max(health - damage, 0)
	update_health_bar()
	if health == 0:
		die()

func update_health_bar():
	# Update the health bar's value
	if $CanvasLayer and $CanvasLayer/TextureProgressBar:
		$CanvasLayer/TextureProgressBar.value = health
		$CanvasLayer.visible = health < mob_health
	else:
		print_debug("Error: Health bar nodes are missing!")

func die():
	# Logic for when the mob dies
	print_debug("Mob has died!")  # Debug message for testing
	if $CanvasLayer:
		$CanvasLayer.queue_free()  # Optional: Remove the health bar
	queue_free()  # Remove the mob from the scene

func _ready() -> void:
	pass
 
func _process(_delta: float) -> void:
	pass
