extends RigidBody2D

@export var max_health: float = 1
@export var movement_speed: float = -100.0

var health: float = max_health  # Current health

# Required for shoot_projectile()
@export var projectile_scene: PackedScene
@export var shooting_speed: float = 500.0
@export var target: CharacterBody2D

# Coin stuff.
@export var coins_dropped: int = 10

# Sound thing
@onready var attacks_sound_player = $AttackPlayer  

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
		health_bar.max_value = max_health
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

	remove_on_camera_exit()

func coin_explosion() -> void:
	for i in range(coins_dropped):
		var coin_sprite := preload("res://scenes/coin.tscn").instantiate()
		coin_sprite.global_position = $Node2D.global_position
				
		add_sibling(coin_sprite)
		# give some initial velocity in a random direction to make it "explode"
		coin_sprite.linear_velocity = Vector2(8000, 0).rotated(randf_range(0.0, TAU))
		coin_sprite.despawn.connect(func(): Globals.add_coins(1))

func remove_on_camera_exit() -> void:
	# Get the active Camera2D
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return
	
	# Calculate the camera's visible area in world coordinates
	var camera_rect = Rect2(camera.global_position - (get_viewport_rect().size / 2) / camera.zoom, get_viewport_rect().size / camera.zoom)

	# Clamp the character's position within the camera's visible area
	if position.x < camera_rect.position.x:
		queue_free()
		
func shoot_projectile() -> void:
	# If no target is explicitly assigned, attempt to find a node named "Idiot_hero" in the current scene.
	if not target:
		var idiot = get_tree().get_current_scene().get_node("Idiot_hero")
		if idiot and idiot is CharacterBody2D:
			target = idiot
		else:
			print("No valid 'Idiot_hero' node found in the scene.")

	# Create a new instance of the projectile
	var projectile = projectile_scene.instantiate()
	
	# Keep track of the shooter (bat)
	projectile.shooter = self
	
	# Position the projectile where the bat currently is.
	projectile.global_position = global_position


	# Determine the direction from the bat to the target.
	var direction = (target.global_position - global_position).normalized()

	# If the projectile is a RigidBody2D, give it a velocity in the calculated direction.
	if projectile is RigidBody2D:
		projectile.linear_velocity = direction * shooting_speed + target.velocity

	if attacks_sound_player and attacks_sound_player.stream:
		attacks_sound_player.play()
	# Add the new projectile to the active scene so it appears in the game.
	get_tree().get_current_scene().add_child(projectile)
