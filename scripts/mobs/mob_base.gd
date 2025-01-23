extends RigidBody2D

@export var max_health: float = 1
@export var movement_speed: float = -100.0

var health: float = max_health  # Current health

@onready var health_bar = $Node2D/TextureProgressBar
@onready var collision_shape = get_node_or_null("CollisionShape2D")  # Adjusted to reference CollisionShape2D directly

func _ready() -> void:
	# Initialize the health bar if it exists
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health
	else:
		print("Health bar not found!")

	# Log collision shape status
	if not collision_shape:
		print("Warning: CollisionShape2D not found!")

func take_damage(amount: float) -> void:
	health = max(health - amount, 0)
	update_health_bar()

	if health <= 0:
		die()

func update_health_bar() -> void:
	if health_bar:
		health_bar.value = health
	else:
		print("Health bar not found!")

func die() -> void:
	print("Mob has died!")
	queue_free()  # Remove mob from the scene

func _physics_process(delta: float) -> void:
	# Ensure the health bar follows the collision shape's position if available
	if collision_shape:
		$Node2D.position = collision_shape.global_position + Vector2(0, -20)  # Adjust offset as needed
	else:
		print("CollisionShape2D not found!")

	# Update position based on movement speed
	position.x += movement_speed * delta
