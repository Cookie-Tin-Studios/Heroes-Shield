extends CharacterBody2D 

# Health variables
@export var max_health: int = 3  # Default max health
@onready var health_bar = $HealthBar
var current_health: int = max_health


# Movement Variables:
@export var acceleration: float = 4000
@export var deceleration: float = 4000
@export var friction: float = 0.8
@export var speed: float = 800

# Reference to the hero node
@export var idiot_hero: Node

# Container for orientation
@onready var flip_container = $FlipContainer
@onready var health_bar_starting_position = health_bar.position

func _ready():
	# Initialize health
	current_health = max_health
	$FlipContainer/ParryArea.body_entered.connect(_on_parry_area_body_entered) # parrymech
	$FlipContainer/ParryArea.body_exited.connect(_on_parry_area_body_exited) # parrymech
	call_deferred("create_health_sections")
	
	idiot_hero = get_node("../Idiot_hero")
	if idiot_hero == null:
		print("Shield: Hero path is not set!")
		return

func update_health_bar():
	health_bar.update_health(current_health)

# Function to take damage
func take_damage(amount: int):
	current_health -= amount
	update_health_bar()

	if current_health <= 0:
		die()

# Function called when health reaches 0
func die():
	print("Character has died!")
	queue_free()  # Remove the character from the scene


# Speed of movement
func _process(_delta: float) -> void:
	var input_dir = Vector2.ZERO
	idiot_hero = get_node("../Idiot_hero")
	# Ensure the hero node exists
	if idiot_hero == null:
		print("Shield: Cannot find the hero node!")
		return
	

	if Input.is_action_pressed("ui_up"):
		input_dir.y -= 1
	if Input.is_action_pressed("ui_down"):
		input_dir.y += 1
	if Input.is_action_pressed("ui_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_dir.x += 1
	
	
	# Normalize direction for consistent movement
	input_dir = input_dir.normalized()

	var target_velocity
	if input_dir == Vector2.ZERO:
		target_velocity = idiot_hero.velocity
	else:
		target_velocity = input_dir * speed
	
	# Accelerate towards desired velocity
	velocity = velocity.move_toward(target_velocity, acceleration * _delta)

	# Apply friction when no input
	if input_dir == Vector2.ZERO:
		velocity = velocity * pow(friction, _delta) 
	
	# Move the character
	move_and_slide()
	# Restrict the character to stay within the camera's visible bounds
	restrict_to_camera()

	# Parry attempt parry if input pressed. parrymech
	if Input.is_action_just_pressed("parry"):
		attempt_parry()
	
	# Flip the FlipContainer based on position
	if global_position.x > idiot_hero.global_position.x:
		flip_container.scale.y = 1  # Flip horizontally
	else:
		flip_container.scale.y = -1 # Reset to normal
	
	health_bar.scale = Vector2(1, 1)
	# Calculate direction from hero to the shield
	var direction_to_hero = global_position - idiot_hero.global_position
	
	# Make the shield face away from the hero
	rotation = direction_to_hero.angle()
#	

func restrict_to_camera() -> void:
	# Get the active Camera2D
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return
	
	# Calculate the camera's visible area in world coordinates
	var camera_rect = Rect2(camera.global_position - (get_viewport_rect().size / 2) / camera.zoom, get_viewport_rect().size / camera.zoom)

	# Clamp the character's position within the camera's visible area
	position.x = clamp(position.x, camera_rect.position.x, camera_rect.position.x + camera_rect.size.x)
	position.y = clamp(position.y, camera_rect.position.y, camera_rect.position.y + camera_rect.size.y)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("projectiles"):  # Check if the body is in the 'projectiles' group
		take_damage(1)  # Assume the projectile has a `damage` property
		body.queue_free()  # Remove the projectile after collision



########### FOR PARRYING MECHANICS ###########
# When we need to move this into it's own script, search for parrymech in this file to find all
# the shit you need to make this work.
var projectiles_in_range: Array[RigidBody2D] = []

# Add to array if projectile in range.
func _on_parry_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("projectiles") and body is RigidBody2D:
		projectiles_in_range.append(body)

# Remove from array after leaving range.
func _on_parry_area_body_exited(body: Node2D) -> void:
	if body in projectiles_in_range:
		projectiles_in_range.erase(body)
	
	if body.is_in_group("mobs"):  # Ensure the goblin is in the "mobs" group
		if body.has_method("take_damage"):
			body.take_damage(1)  # Adjust the parry damage
			print("Parried! Dealt 1 damage to ", body.name)	
	

func attempt_parry() -> void:
	if projectiles_in_range.size() == 0:
		# No projectile in range, don't bother parrying.
		return

	# Reflect every projectile in range.
	for projectile in projectiles_in_range:
		deflect_projectile(projectile)
		Globals.add_coins(1) # This is temporary for testing the coin additonal mechanics.
		
func deflect_projectile(projectile: RigidBody2D) -> void:
	# Set the parry variable to true, so we know it's been parried.
	projectile.parried = true
	# Disable layers for player collisions
	projectile.set_collision_layer_value(1, false)
	projectile.set_collision_mask_value(1, false)
	# Change layer to match mobs (3)
	projectile.set_collision_layer_value(3, true)
	projectile.set_collision_mask_value(3, true)
	# Eventually, we should make it such that parried projectiles fly straight away from the center of the shield.
	projectile.linear_velocity = -projectile.linear_velocity
	# Make it fast as fuck, for the fans.
	projectile.linear_velocity *= 10
