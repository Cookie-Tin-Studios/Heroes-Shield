extends "res://scripts/mobs/mob_base.gd"

# Determines how far above (or below) the collision shape the health bar should appear.
@export var health_bar_offset: Vector2 = Vector2(0, 200)
@export var health_bar_follow_collision: bool = true

# Variable for referencing idiot node
var idiot_hero: Node

# Requried for modifying active animation in functions.
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Connect to global tick
@onready var global_tick = get_node("/root/Tick")

func _ready() -> void:
	super._ready()
	health = 5
	max_health = 5
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
	print("This is a die() function within the boss_1.gd script.")
	animated_sprite.play("on-kill")
	await get_tree().create_timer(1.0).timeout
	coin_explosion()
	
	Globals.add_coins(coins_dropped) # Give the player however COINZ.
	queue_free()  # Remove mob from the scene
	
