extends CharacterBody2D

# --- Health variables ---
@export var max_health: int = 3
@onready var health_bar = $HealthBar
var current_health: int = max_health
@export var isInvincible: bool = false

# --- Movement variables ---
@export var acceleration: float = 4000
@export var deceleration: float = 6000
@export var friction: float = 0.8
@export var speed: float = 800
@export var speed_multiplier: float = 1.0

# Reference to a "hero" node (for movement/flipping), but NOT used for parry direction
@export var idiot_hero: Node

# Container for orientation
@onready var flip_container = $FlipContainer
@onready var health_bar_starting_position = health_bar.position

# parry variables
var projectiles_in_range: Array[RigidBody2D] = []
@onready var parry_sound_player = $ParrySoundPlayer  

# dash variables
@export var dash_speed: float = 3000.0
@export var dash_duration: float = 0.5
@export var dash_cooldown: float = 1.0
@export var dash_damage: int = 1

var is_dashing: bool = false
var can_dash: bool = true
var dash_timer: float = 0.0


func _ready() -> void:
	# Initialize health
	current_health = max_health
	call_deferred("create_health_sections")

	# Movement Upgrades
	if Globals.movementSpeed1 in Globals.unlocked_upgrades[Globals.movementCategory]:
		speed *= 1.1
	if Globals.movementSpeed2 in Globals.unlocked_upgrades[Globals.movementCategory]:
		speed *= 1.2

	# Ensure the hero node is accessible (only used for movement/position checks, not reflection)
	idiot_hero = get_node("../Idiot_hero")
	if idiot_hero == null:
		print("Shield: Hero path is not set!")

func _process(delta: float) -> void:
	var input_dir = Vector2.ZERO

	# --- same input logic as before ---
	if Input.is_action_pressed("ui_up"):
		input_dir.y -= 1
	if Input.is_action_pressed("ui_down"):
		input_dir.y += 1
	if Input.is_action_pressed("ui_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_dir.x += 1

	input_dir = input_dir.normalized()

	var final_speed = speed
	# Use speed_multiplier
	final_speed *= speed_multiplier
	var target_velocity: Vector2
	if input_dir == Vector2.ZERO:
		target_velocity = idiot_hero.velocity
	else:
		target_velocity = input_dir * final_speed

	velocity = velocity.move_toward(target_velocity, acceleration * delta)
	
	if velocity.length() <= speed and $ShieldDash.has_effect:
		print("removing speed effect")
		$ShieldDash.remove_effect()
	elif velocity.length() > speed and not $ShieldDash.has_effect:
		print("granting speed effect")
		$ShieldDash.add_effect()

	# Dash mechanics
	#########################
	# Check if currently dashing
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
			# Start a cooldown timer
			var cooldown_timer := Timer.new()
			cooldown_timer.one_shot = true
			cooldown_timer.wait_time = dash_cooldown
			add_child(cooldown_timer)
			cooldown_timer.start()
			cooldown_timer.timeout.connect(Callable(self, "_on_dash_cooldown_finished"))
	else:
		# Only allow dash if not already dashing and not on cooldown
		if can_dash and Input.is_action_just_pressed("shield_dash"):
			# Check if you have unlocked the dash upgrade
			if Globals.movementSpeed3 in Globals.unlocked_upgrades[Globals.movementCategory]:
				dash()

	# Friction if no movement input
	if input_dir == Vector2.ZERO:
		velocity *= pow(friction, delta)

	move_and_slide()
	restrict_to_camera()

	# Attempt parry if parry input is just pressed
	if Input.is_action_just_pressed("parry"):
		attempt_parry()

	# Optional: Flip the shield based on relative position to the hero
	if global_position.x > idiot_hero.global_position.x:
		flip_container.scale.y = 1    # Not flipped
	else:
		flip_container.scale.y = -1   # Flipped horizontally

	# Keep the health bar normal scale
	health_bar.scale = Vector2(1, 1)

	# If you still want to face away from hero, keep the next lines:
	var direction_to_hero = global_position - idiot_hero.global_position
	rotation = direction_to_hero.angle()
	# needed for the effect to show up
	$ShieldDash.position = global_position
	$ShieldDash.rotation = rotation
 

########################################################################
# HEALTH MANAGEMENT
########################################################################

func update_health_bar() -> void:
	health_bar.update_health(current_health)

func take_damage(amount: int) -> void:
	if isInvincible:
		return
		
	current_health -= amount
	update_health_bar()
	if current_health <= 0:
		die()

func die() -> void:
	print("Character has died!")
	queue_free()
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("projectiles"):
		take_damage(1)
		body.queue_free()  # Destroy the projectile
	
########################################################################
# SPEED BOOST
########################################################################
	
func apply_speed_boost(boost_factor: float, duration: float) -> void:
	speed_multiplier *= boost_factor
	
	var timer := Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	add_child(timer)
	timer.start()

	# Create a Callable for the revert_speed_boost method, binding the boost_factor.
	var revert_callable = Callable(self, "revert_speed_boost").bind(boost_factor)

	# Connect the timeout signal to that Callable
	timer.timeout.connect(revert_callable)

func revert_speed_boost(boost_factor: float) -> void:
	speed_multiplier /= boost_factor
	
	
########################################################################
# Invincibility
########################################################################
	
func apply_invincibility(duration: float) -> void:	
	var timer := Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	add_child(timer)
	timer.start()
	isInvincible = true

	# Create a Callable for the revert_speed_boost method, binding the boost_factor.
	var revert_callable = Callable(self, "revert_invincibility")

	# Connect the timeout signal to that Callable
	timer.timeout.connect(revert_callable)
	

func revert_invincibility() -> void:
	isInvincible = false


########################################################################
# MOVEMENT
########################################################################

func restrict_to_camera() -> void:
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return

	var camera_rect = Rect2(
		camera.global_position - (get_viewport_rect().size / 2) / camera.zoom,
		get_viewport_rect().size / camera.zoom
	)

	position.x = clamp(position.x, camera_rect.position.x, camera_rect.position.x + camera_rect.size.x)
	position.y = clamp(position.y, camera_rect.position.y, camera_rect.position.y + camera_rect.size.y)

########################################################################
# PARRY
########################################################################

func _on_parry_area_body_entered(body: Node2D) -> void:
	# If we are currently dashing:
	if is_dashing:
		if body.is_in_group("projectiles") and body is RigidBody2D:
			# Immediately parry the projectile (instead of waiting for user to press parry).
			deflect_projectile(body)
		elif body.is_in_group("mobs"):
			# Apply dash_damage
			if body.has_method("take_damage"):
				body.take_damage(dash_damage)
				print("Dash hit! Dealt %s damage to %s" % [dash_damage, body.name])
			
			# Apply a knockback impulse if the mob is a RigidBody2D:
			if body is RigidBody2D:
				var knockback_dir = (body.global_position - global_position).normalized()
				# Tweak the strength as needed:
				body.apply_central_impulse(knockback_dir * 1000)
	
	else:
		# If we are NOT dashing, fall back to normal parry behavior
		# (append projectiles to projectiles_in_range if they are in group "projectiles")
		if body.is_in_group("projectiles") and body is RigidBody2D:
			projectiles_in_range.append(body)

func _on_parry_area_body_exited(body: Node2D) -> void:
	if body in projectiles_in_range:
		projectiles_in_range.erase(body)

	if body.is_in_group("mobs"):
		if body.has_method("take_damage"):
			body.take_damage(1)
			print("Parried! Dealt 1 damage to ", body.name)


func attempt_parry() -> void:
	if projectiles_in_range.size() == 0:
		return

	for projectile in projectiles_in_range:
		deflect_projectile(projectile)

func deflect_projectile(projectile: RigidBody2D) -> void:
	projectile.parried = true

	# Collision layers
	projectile.set_collision_layer_value(1, false)
	projectile.set_collision_mask_value(1, false)
	projectile.set_collision_layer_value(3, true)
	projectile.set_collision_mask_value(3, true)

	var normal = (projectile.global_position - global_position).normalized()
	var bounced_vel = projectile.linear_velocity.bounce(normal)

	# Weighted blend: e.g. 70% real reflection, 30% guaranteed radial outward
	var radial_out = normal * 1000.0
	var alpha = 0.7  # 70% reflection, 30% radial

	var new_velocity = bounced_vel.lerp(radial_out, 1.0 - alpha)

	# 5) Multiply the final velocity by 10 for that big "ping"
	new_velocity *= 5.0

	projectile.linear_velocity = new_velocity
	
	# Play the parry sound effect
	if parry_sound_player and parry_sound_player.stream:
		parry_sound_player.play()

########################################################################
# DASH
########################################################################

func dash() -> void:
	is_dashing = true
	can_dash = false
	dash_timer = dash_duration
	
	if velocity.length() < 10.0:
		pass  # Optional: Decide how to handle near-zero velocity

	velocity = velocity.normalized() * dash_speed
	
func _on_dash_cooldown_finished() -> void:
	can_dash = true
