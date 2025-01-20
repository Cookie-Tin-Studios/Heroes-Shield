extends "res://scripts/mobs/mob_base.gd"

@onready var global_tick = get_node("/root/Tick")  # Timer or global tick for periodic shooting

@export var projectile_scene: PackedScene  # Scene for the projectile
@export var shooting_speed: float = 500.0  # Speed of the projectile
@export var target: CharacterBody2D        # Target for the projectile (e.g., player)

@export var health_bar_offset: Vector2 = Vector2(0, -20)  # Offset for health bar relative to collision box
@export var health_bar_follow_collision: bool = true      # Whether the health bar follows the collision box


func _ready() -> void:
	super._ready()
	

	# Connect global tick to projectile shooting
	global_tick.timeout.connect(_on_tick)

func _on_tick() -> void:
	shoot_projectile()

func shoot_projectile() -> void:
	# Attempt to auto-find the player node named "Idiot_hero"
	if not target:
		var idiot = get_tree().get_current_scene().get_node("Idiot_hero")
		if idiot and idiot is CharacterBody2D:
			target = idiot
		else:
			print("No valid 'Idiot_hero' node found in the scene.")

	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position

	# Calculate direction toward the target
	var direction = (target.global_position - global_position).normalized()

	# Assign velocity to the projectile (if it's a RigidBody2D)
	if projectile is RigidBody2D:
		projectile.linear_velocity = direction * shooting_speed

	get_tree().get_current_scene().add_child(projectile)
	print("Projectile shot at target!")

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	# Lock health bar position to collision box if enabled
	if health_bar_follow_collision and $CollisionShape2D and $Node2D:
		var collision_pos = $CollisionShape2D.position
		$Node2D.position = collision_pos + health_bar_offset
