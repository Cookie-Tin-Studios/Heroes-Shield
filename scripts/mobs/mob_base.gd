extends RigidBody2D

@export var max_health: float = 1
@export var movement_speed: float = -100.0

var health: float = max_health  # Current health

# Coin stuff.
var coins_dropped: int = 10 # Variable for coins, can be overloaded in child scripts.
@export var coin_texture: Texture2D = preload("res://assets/sprites/HIM.png")
# End coin stuff.

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
	coin_explosion()
	
	Globals.add_coins(coins_dropped) # Give the player however COINZ.
	queue_free()  # Remove mob from the scene

func _physics_process(delta: float) -> void:
	# Ensure the health bar follows the collision shape's position if available
	if collision_shape:
		$Node2D.position = collision_shape.global_position + Vector2(0, -20)  # Adjust offset as needed
	else:
		print("CollisionShape2D not found!")

	# Update position based on movement speed
	position.x += movement_speed * delta

func coin_explosion() -> void:
	for i in range(coins_dropped):
		var coin_sprite := Sprite2D.new()
		coin_sprite.texture = coin_texture
		coin_sprite.global_position = $Node2D.global_position
		
		add_sibling(coin_sprite)

		var random_direction := Vector2(1, 0).rotated(randf_range(0.0, TAU))
		var random_distance := randf_range(75.0, 150.0)
		var final_position := coin_sprite.position + random_direction * random_distance

		var tween := get_tree().create_tween()

		# Move from current position to final_position over 0.5s
		tween.tween_property(coin_sprite, "position", final_position, 0.1)

		# Fade alpha from 1.0 to 0.0 over 0.5s
		tween.tween_property(coin_sprite, "modulate:a", 0.0, 0.5).from(1.0)

		# Connect the finished signal with an inline function
		tween.finished.connect(func():
			coin_sprite.queue_free()
		)
