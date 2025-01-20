extends RigidBody2D

@export var max_health: float = 100
# The maximum health this mob can have. Adjust to make enemies tougher or weaker.

var health: float = max_health
# Tracks the mob's current health, initialized to the maximum.

@export var movement_speed: float = -100.0
# Controls how fast (and in which direction) the mob moves each physics frame.

func _ready() -> void:
	# Initialize the health bar when the mob is added to the scene.
	# This sets both the max value and the current value.
	if $Node2D/TextureProgressBar:
		$Node2D/TextureProgressBar.max_value = max_health
		$Node2D/TextureProgressBar.value = health

func take_damage(amount: float) -> void:
	# Reduce the mob's health by 'amount', but never below zero.
	health = max(health - amount, 0)
	
	# Update the health bar to reflect the new health total.
	update_health_bar()

	# If health reaches zero, trigger the mob's death.
	if health <= 0:
		die()

func update_health_bar() -> void:
	# Sync the TextureProgressBar node to match the 'health' variable.
	if $Node2D/TextureProgressBar:
		$Node2D/TextureProgressBar.value = health
	else:
		print("Health bar not found!")

func die() -> void:
	# Print a diagnostic message, then remove this mob from the scene.
	print("Mob has died!")
	queue_free()

func _physics_process(delta: float) -> void:
	# Move the mob along the x-axis based on 'movement_speed' every physics frame.
	position.x += movement_speed * delta

	# Keep the health bar Node2D synced with the CollisionShape2D's position (if both exist).
	if $Node2D and $CollisionShape2D:
		var collision_pos = $CollisionShape2D.position
		$Node2D.position = collision_pos + Vector2(0, 0)  # Adjust the offset as needed.
