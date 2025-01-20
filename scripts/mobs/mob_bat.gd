extends "res://scripts/mobs/mob_base.gd"

@onready var global_tick = get_node("/root/Tick")  # Timer or global tick for periodic shooting

@export var projectile_scene: PackedScene  # Scene for the projectile
@export var shooting_speed: float = 500.0  # Speed of the projectile
@export var target: CharacterBody2D        # Target for the projectile (e.g., player)

@export var health_bar_offset: Vector2 = Vector2(0, -20)  # Offset for health bar relative to collision box
@export var health_bar_follow_collision: bool = true      # Whether the health bar follows the collision box

func _ready() -> void:

	# Connect global tick to projectile shooting
	global_tick.timeout.connect(_on_tick)

	# Call parent class's _ready()
	super._ready()

func _on_tick() -> void:
	# Shoot a projectile on each tick
	shoot_projectile()

func shoot_projectile() -> void:
	if not target:
		print("Error: Missing target or projectile scene!")
		return

	# Instantiate the projectile scene
	var projectile = projectile_scene.instantiate()

	# Set the projectile's initial position to the bat's position
	projectile.global_position = global_position

	# Calculate direction toward the target
	var direction = (target.global_position - global_position).normalized()

	# Assign velocity to the projectile
	if projectile is RigidBody2D:
		projectile.linear_velocity = direction * shooting_speed

	# Add projectile to the current scene
	get_tree().get_current_scene().add_child(projectile)
	print("Projectile shot at target!")

func _physics_process(delta: float) -> void:
	# Call the parent class's movement logic
	super._physics_process(delta)

	# Lock health bar position to collision box if enabled
	if health_bar_follow_collision and $CollisionShape2D and $Node2D:
		var collision_pos = $CollisionShape2D.position
		$Node2D.position = collision_pos + health_bar_offset

func _on_body_entered(body: Node) -> void:
	# Handle collision with the player
	if body is CharacterBody2D and body.name == "Idiot_hero":
		print("Collision detected with player. Game over!")
		get_tree().change_scene_to_file("res://scenes/menu/game_over.tscn")
