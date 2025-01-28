extends "res://scripts/mobs/mob_base.gd"

# Determines how far above (or below) the collision shape the health bar should appear.
@export var health_bar_offset: Vector2 = Vector2(-100, 200)
@export var health_bar_follow_collision: bool = true

# Variable for referencing idiot node
var idiot_hero: Node

# Defines a scene to be used for the rails.
var rail_scene = preload("res://scenes/bosses/rail.tscn")
# Defines when we spawn each rail
var top_rail_health: int
var bottom_rail_health: int
var rear_rail_health: int
# Defines shooting stages
var shoot_stage_1_health: int
var shoot_stage_2_health: int
# Controls fire rate for this scene
var shots_until_fire = 0             # Internal counter
@export var fire_interval = 1        # How many ticks to wait before firing again (tweak as needed)


# Requried for modifying active animation in functions.
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Connect to global tick
@onready var global_tick = get_node("/root/Tick")

func _ready() -> void:
	# Use the parent script's ready function.
	super._ready()
	# Change mob-specific variables from mob_base.
	health = 10
	max_health = 10
	coins_dropped = 10
	# These variables are specific to this boss, for when to spawn the rails.
	top_rail_health = 7
	bottom_rail_health = 7
	rear_rail_health = 3
	# These variables are specific to this boss, for when to switch up the shooting methods.
	shoot_stage_1_health = 7
	shoot_stage_2_health = 5
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
		animated_sprite.play("idle")
	
	# We use this to slow down the firing in the later stages.
	# Otherwise it's BONKERS HARD to beat it.
	shots_until_fire += 1
	
	if shots_until_fire >= fire_interval:
		shots_until_fire = 0  # Reset counter

		# Shoot normally if health hasn't hit stage 1
		if health > shoot_stage_1_health:
			shoot_projectile()
		
		# If health below stage 1 but above stage 2, run stage 1
		if health <= shoot_stage_1_health and health > shoot_stage_2_health:
			shoot_stage_1()
			fire_interval = 2 # Slows down firing.
			
		# If health equal or below stage 2, run stage 2.
		if health <= shoot_stage_2_health:
			shoot_stage_2()
			fire_interval = 3 # Slows down firing even more.

func when_hit() -> void:
	if health != 0:
		animated_sprite.play("on-hit")
		
	if int(health) == top_rail_health:
		spawn_top_rail()
	if int(health) == bottom_rail_health:
		spawn_bottom_rail()
	if int(health) == rear_rail_health:
		spawn_rear_rail()

# Note that this overloads the parent die function. This is so that we can play the on-death animation for a second before dying.
func die() -> void:
	print("This is the die() function within the boss_1.gd script.")
	animated_sprite.play("on-kill")
	await get_tree().create_timer(1.0).timeout
	coin_explosion()
	
	Globals.add_coins(coins_dropped) # Give the player however COINZ.
	queue_free()  # Remove mob from the scene

# Yeah, I know this is fuckin' stupid. Sue me.
func spawn_bottom_rail() -> void:
	# Haha bottom rail, me when the femboys are out be like
	var bottom_rail = rail_scene.instantiate()
	bottom_rail.start_pos = Vector2(-5000, 1000)
	bottom_rail.end_pos = Vector2(1000, 1000)
	add_child(bottom_rail)
	print("Top rail added")

# Yeah, I know this is fuckin' stupid. Sue me.
func spawn_rear_rail() -> void:
	# Haha rear rail if you know what I mean homies
	var rear_rail = rail_scene.instantiate()
	rear_rail.start_pos = Vector2(-3500, 2000)
	rear_rail.end_pos = Vector2(-3500, -2000)
	add_child(rear_rail)
	print("Rear rail added")

# Yeah, I know this is fuckin' stupid. Sue me.
func spawn_top_rail() -> void:
	# You thought the other ones were funny didn't you, you sick fuck
	var top_rail = rail_scene.instantiate()
	top_rail.start_pos = Vector2(-5000,-1000)
	top_rail.end_pos = Vector2(1000, -1000)
	add_child(top_rail)
	print("Top rail added")

# These directions are required for firing in the shoot_stage_X functions.
var direction_nw = Vector2(-1, -1).normalized()
var direction_sw = Vector2(-1,  1).normalized()
var direction_w = Vector2(-1,  0).normalized()
func shoot_stage_1() -> void:
	# Put a lil' sauce on it. +-10 deg shoot angle for more chaos.
	# Note that this will be re-randomized for every shot, intentionally, for extra bullshit.
	var angle_offset = deg_to_rad(randf_range(-10.0, 10.0))

	# North West projectile.
	var final_direction_nw = direction_nw.rotated(angle_offset)
	var projectile_nw = projectile_scene.instantiate()
	projectile_nw.global_position = global_position
	projectile_nw.linear_velocity = final_direction_nw * shooting_speed
	get_tree().get_current_scene().add_child(projectile_nw)
	
	# Get a fresh random +-10 deg angle for evil.
	angle_offset = deg_to_rad(randf_range(-10.0, 10.0))
	# South West projectile.
	var final_direction_sw = direction_sw.rotated(angle_offset)
	var projectile_sw = projectile_scene.instantiate()
	projectile_sw.global_position = global_position
	projectile_sw.linear_velocity = final_direction_sw * shooting_speed
	get_tree().get_current_scene().add_child(projectile_sw)
	

func shoot_stage_2() -> void:
	# This func shoots a NW and SW projectile.
	shoot_stage_1()
	# Then we add a third, West projectile.
	
	# Get a fresh random +-10 deg angle for evil.
	var angle_offset = deg_to_rad(randf_range(-10.0, 10.0))
	# South West projectile.
	var final_direction_w = direction_w.rotated(angle_offset)
	var projectile_w = projectile_scene.instantiate()
	projectile_w.global_position = global_position
	projectile_w.linear_velocity = final_direction_w * shooting_speed
	get_tree().get_current_scene().add_child(projectile_w)
