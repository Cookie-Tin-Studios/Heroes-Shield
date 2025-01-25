extends CharacterBody2D

# Health variables
@export var max_health: int = 3
@onready var health_bar = $HealthBar
var current_health: int = max_health

# Movement variables
@export var acceleration: float = 4000
@export var deceleration: float = 4000
@export var friction: float = 0.8
@export var speed: float = 800

# Reference to the hero node (the "Idiot_hero")
@export var idiot_hero: Node

# Container for orientation
@onready var flip_container = $FlipContainer
@onready var health_bar_starting_position = health_bar.position

# Keep track of projectiles within parry range
var projectiles_in_range: Array[RigidBody2D] = []

func _ready() -> void:
	# Initialize health
	current_health = max_health
	call_deferred("create_health_sections")

	# Ensure we can access the hero node
	idiot_hero = get_node("../Idiot_hero")
	if idiot_hero == null:
		print("Shield: Hero path is not set!")

func update_health_bar() -> void:
	health_bar.update_health(current_health)

func take_damage(amount: int) -> void:
	current_health -= amount
	update_health_bar()

	if current_health <= 0:
		die()

func die() -> void:
	print("Character has died!")
	queue_free()  # Remove the character from the scene

func _process(delta: float) -> void:
	var input_dir = Vector2.ZERO

	# Make sure the hero node still exists
	idiot_hero = get_node("../Idiot_hero")
	if idiot_hero == null:
		print("Shield: Cannot find the hero node!")
		return

	# Basic movement inputs
	if Input.is_action_pressed("ui_up"):
		input_dir.y -= 1
	if Input.is_action_pressed("ui_down"):
		input_dir.y += 1
	if Input.is_action_pressed("ui_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_dir.x += 1

	input_dir = input_dir.normalized()

	var target_velocity: Vector2
	if input_dir == Vector2.ZERO:
		target_velocity = idiot_hero.velocity
	else:
		target_velocity = input_dir * speed

	# Accelerate toward the target velocity
	velocity = velocity.move_toward(target_velocity, acceleration * delta)

	# Apply friction if no movement input
	if input_dir == Vector2.ZERO:
		velocity *= pow(friction, delta)

	move_and_slide()
	restrict_to_camera()

	# Attempt parry if the parry input is just pressed
	if Input.is_action_just_pressed("parry"):
		attempt_parry()

	# Flip the shield based on relative position to hero
	if global_position.x > idiot_hero.global_position.x:
		flip_container.scale.y = 1   # Not flipped
	else:
		flip_container.scale.y = -1  # Flipped horizontally

	health_bar.scale = Vector2(1, 1)

	# Rotate the shield so it faces away from the hero
	var direction_to_hero = global_position - idiot_hero.global_position
	rotation = direction_to_hero.angle()

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

# Called when something enters this body’s main collision shape
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("projectiles"):
		take_damage(1)
		body.queue_free()  # Destroy the projectile

# Parry area callbacks: track which projectiles are in parry range
func _on_parry_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("projectiles") and body is RigidBody2D:
		projectiles_in_range.append(body)

func _on_parry_area_body_exited(body: Node2D) -> void:
	if body in projectiles_in_range:
		projectiles_in_range.erase(body)

	if body.is_in_group("mobs"):  # e.g. if you also want parry to affect mobs
		if body.has_method("take_damage"):
			body.take_damage(1)
			print("Parried! Dealt 1 damage to ", body.name)

# Called when the player presses the parry action
func attempt_parry() -> void:
	if projectiles_in_range.size() == 0:
		return

	# Reflect every projectile currently in range
	for projectile in projectiles_in_range:
		deflect_projectile(projectile)

func deflect_projectile(projectile: RigidBody2D) -> void:
	# Mark the projectile as parried
	projectile.parried = true

	# Update collision layers: remove from player layer (1), add to mob layer (3)
	projectile.set_collision_layer_value(1, false)
	projectile.set_collision_mask_value(1, false)
	projectile.set_collision_layer_value(3, true)
	projectile.set_collision_mask_value(3, true)

	# Use reflection to bounce the projectile’s velocity.
	# The shield faces away from the hero, so the "normal" we reflect against can
	# be taken from the direction from hero -> shield (or vice versa, depending on orientation).
	var direction_to_hero = global_position - idiot_hero.global_position
	var shield_normal = direction_to_hero.normalized()

	# bounce() = v - 2 * (v dot n) * n
	# This reflects the projectile velocity around the normal.
	var new_velocity = projectile.linear_velocity.bounce(shield_normal)

	# Multiply by some factor for a dramatic deflection effect
	new_velocity *= 10

	projectile.linear_velocity = new_velocity
