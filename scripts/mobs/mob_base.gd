extends RigidBody2D

@export var max_health: float = 100
var health: float = max_health

@export var movement_speed: float = -100.0

func _ready() -> void:
	# Initialize the health bar
	if $Node2D/TextureProgressBar:
		$Node2D/TextureProgressBar.max_value = max_health
		$Node2D/TextureProgressBar.value = health

func take_damage(amount: float) -> void:
	health = max(health - amount, 0)  # Ensure health doesn't go below 0
	update_health_bar()

	if health <= 0:
		die()

func update_health_bar() -> void:
	if $Node2D/TextureProgressBar:
		$Node2D/TextureProgressBar.value = health
	else:
		print("Health bar not found!")

func die() -> void:
	print("Mob has died!")
	queue_free()

func _physics_process(delta: float) -> void:
	# Move the mob
	position.x += movement_speed * delta

	# Lock the health bar position to the collision box
	if $Node2D and $CollisionShape2D:
		var collision_pos = $CollisionShape2D.position
		$Node2D.position = collision_pos + Vector2(0, 0)  # Adjust offset as needed
