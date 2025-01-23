extends "res://scripts/mobs/mob_base.gd"

@onready var global_tick = get_node("/root/Tick") 
@export var projectile_scene: PackedScene
@export var shooting_speed: float = 500.0
@export var target: CharacterBody2D

# Determines how far above (or below) the collision shape the health bar should appear.
@export var health_bar_offset: Vector2 = Vector2(0, -20)
@export var health_bar_follow_collision: bool = true

func _ready() -> void:
	super._ready()

	# Connect the global tick signal so the bat shoots projectiles periodically.
	global_tick.timeout.connect(_on_tick)

func _on_tick() -> void:
	# Trigger a projectile shot every time the global tick fires.
	shoot_projectile()

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
		projectile.linear_velocity = direction * shooting_speed

	# Add the new projectile to the active scene so it appears in the game.
	get_tree().get_current_scene().add_child(projectile)
	print("Projectile shot at target!")

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	# If enabled, place the health bar above the collision shape by the specified offset.
	if health_bar_follow_collision and $CollisionShape2D and $Node2D:
		var collision_pos = $CollisionShape2D.position
		$Node2D.position = collision_pos + health_bar_offset
