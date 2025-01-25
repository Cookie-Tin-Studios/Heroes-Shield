extends CharacterBody2D

# --- Health variables ---
@export var max_health: int = 3
@onready var health_bar = $HealthBar
var current_health: int = max_health

# --- Movement variables ---
@export var acceleration: float = 4000
@export var deceleration: float = 4000
@export var friction: float = 0.8
@export var speed: float = 800

# Reference to a "hero" node (for movement/flipping), but NOT used for parry direction
@export var idiot_hero: Node

# Container for orientation
@onready var flip_container = $FlipContainer
@onready var health_bar_starting_position = health_bar.position

# Track projectiles in parry range
var projectiles_in_range: Array[RigidBody2D] = []

func _ready() -> void:
	# Initialize health
	current_health = max_health
	call_deferred("create_health_sections")

	# Ensure the hero node is accessible (only used for movement/position checks, not reflection)
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
	queue_free()

func _process(delta: float) -> void:
	var input_dir = Vector2.ZERO

	# If you still want to anchor movement logic around the hero’s velocity, do so;
	# otherwise, remove references to idiot_hero if not needed.
	if not is_instance_valid(idiot_hero):
		print("Shield: Cannot find the hero node!")
		return

	# --- Basic movement inputs ---
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
		# If no direct input, maybe match hero velocity or keep shield still.
		target_velocity = idiot_hero.velocity
	else:
		target_velocity = input_dir * speed

	velocity = velocity.move_toward(target_velocity, acceleration * delta)

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

# --- Main collision shape events ---
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("projectiles"):
		take_damage(1)
		body.queue_free()  # Destroy the projectile

# --- Parry area callbacks ---
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

# --- Parry logic ---
func attempt_parry() -> void:
	if projectiles_in_range.size() == 0:
		return

	for projectile in projectiles_in_range:
		deflect_projectile(projectile)

func deflect_projectile(projectile: RigidBody2D) -> void:
	# Mark the projectile as parried
	projectile.parried = true

	# Switch collision layers: remove from player collisions (layer 1), add to mob collisions (layer 3)
	projectile.set_collision_layer_value(1, false)
	projectile.set_collision_mask_value(1, false)
	projectile.set_collision_layer_value(3, true)
	projectile.set_collision_mask_value(3, true)

	# Compute reflection from the *shield’s center* to the projectile’s position
	# so it bounces "away" from the shield.
	var normal = (projectile.global_position - global_position).normalized()

	# Reflect the projectile’s velocity around that normal
	var new_velocity = projectile.linear_velocity.bounce(normal)

	# Dramatic speed boost for satisfying parry
	new_velocity *= 10.0

	projectile.linear_velocity = new_velocity
