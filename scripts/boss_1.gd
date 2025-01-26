extends "res://scripts/mobs/mob_base.gd"

# Determines how far above (or below) the collision shape the health bar should appear.
@export var health_bar_offset: Vector2 = Vector2(-100, 200)
@export var health_bar_follow_collision: bool = true

# Variable for referencing idiot node
var idiot_hero: Node

# Requried for modifying active animation in functions.
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Connect to global tick
@onready var global_tick = get_node("/root/Tick")

func _ready() -> void:
	# Use the parent script's ready function.
	super._ready()
	# Change mob-specific variables from mob_base.
	health = 50 
	max_health = 50
	coins_dropped = 1
	# Connect the global tick signal so the bat shoots projectiles periodically.
	global_tick.timeout.connect(_on_tick)

func _physics_process(delta: float) -> void:
	# This is for making the boss follow the velocity of the idiot, so it stays in a static location.
	# Without this, it'll 'slide' to the left b/c it's not moving relative to the idiot.
	idiot_hero = get_node("../Idiot_hero")
	linear_velocity = idiot_hero.velocity
	
# If enabled, place the health bar above the collision shape by the specified offset.
	if health_bar_follow_collision and $CollisionShape2D and $Node2D:
		var collision_pos = $CollisionShape2D.position
		$Node2D.position = collision_pos + health_bar_offset

# Rooty tooty point n' shooty.
func _on_tick() -> void:
	# Trigger a projectile shot every time the global tick fires.
	if health != 0:
		shoot_projectile()
		animated_sprite.play("idle")

func hurt_animation() -> void:
	if health != 0:
		animated_sprite.play("on-hit")

# Note that this overloads the parent die function. This is so that we can play the on-death animation for a second before dying.
func die() -> void:
	print("This is the die() function within the boss_1.gd script.")
	animated_sprite.play("on-kill")
	await get_tree().create_timer(1.0).timeout
	coin_explosion()
	
	Globals.add_coins(coins_dropped) # Give the player however COINZ.
	queue_free()  # Remove mob from the scene

# Note that this overloads the parent die function. This is so that we can play the on-death animation for a second before dying.

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

	# Add the new projectile to the active scene so it appears in the game.
	get_tree().get_current_scene().add_child(projectile)
	print("Projectile shot at target!")
