extends RigidBody2D

@export var max_health: float = 1
@export var movement_speed: float = -100.0

var health: float = max_health  # Current health

# Coin stuff.
@export var coins_dropped: int = 10

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
	
	#Globals.add_coins(coins_dropped) # Give the player however COINZ.
	queue_free()  # Remove mob from the scene

func _physics_process(delta: float) -> void:
	# Update position based on movement speed
	position.x += movement_speed * delta

	remon_on_camera_exit()

func coin_explosion() -> void:
	for i in range(coins_dropped):
		var coin_sprite := preload("res://scenes/coin.tscn").instantiate()
		coin_sprite.global_position = $Node2D.global_position
				
		add_sibling(coin_sprite)
		# give some initial velocity in a random direction to make it "explode"
		coin_sprite.linear_velocity = Vector2(8000, 0).rotated(randf_range(0.0, TAU))
		coin_sprite.despawn.connect(func(): Globals.add_coins(1))
	

func remon_on_camera_exit() -> void:
	# Get the active Camera2D
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return
	
	# Calculate the camera's visible area in world coordinates
	var camera_rect = Rect2(camera.global_position - (get_viewport_rect().size / 2) / camera.zoom, get_viewport_rect().size / camera.zoom)

	# Clamp the character's position within the camera's visible area
	if position.x < camera_rect.position.x:
		queue_free()
