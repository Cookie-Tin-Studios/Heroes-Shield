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

	# Attempt parry if input pressed
	if Input.is_action_just_pressed("parry"):
		attempt_parry()
	
	# Flip the FlipContainer based on X position relative to hero
	if global_position.x > idiot_hero.global_position.x:
		flip_container.scale.y = 1
	else:
		flip_container.scale.y = -1
	
	# Ensure health bar retains scale
	health_bar.scale = Vector2(1, 1)
	
	# Make the shield face away from the hero
	var direction_to_hero = global_position - idiot_hero.global_position
	rotation = direction_to_hero.angle()

func restrict_to_camera() -> void:
	# Get the active Camera2D
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return
	
	# Calculate the camera's visible area in world coordinates
	var camera_rect = Rect2(
		camera.global_position - (get_viewport_rect().size / 2) / camera.zoom,
		get_viewport_rect().size / camera.zoom
	)

	# Clamp the character's position within the camera's visible area
	position.x = clamp(position.x, camera_rect.position.x, camera_rect.position.x + camera_rect.size.x)
	position.y = clamp(position.y, camera_rect.position.y, camera_rect.position.y + camera_rect.size.y)

func _on_area_2d_body_entered(body: Node2D) -> void:
	# If the body is a projectile, damage the shield and remove the projectile
	if body.is_in_group("projectiles"): 
		take_damage(1)  
		body.queue_free()  

########### FOR PARRYING MECHANICS ###########
var projectiles_in_range: Array[RigidBody2D] = []

func _on_parry_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("projectiles") and body is RigidBody2D:
		projectiles_in_range.append(body)

func _on_parry_area_body_exited(body: Node2D) -> void:
	if body in projectiles_in_range:
		projectiles_in_range.erase(body)

	if body.is_in_group("mobs"):  # For example, if we parry a mob?
		if body.has_method("take_damage"):
			body.take_damage(1)
			print("Parried! Dealt 1 damage to ", body.name)

func attempt_parry() -> void:
	if projectiles_in_range.size() == 0:
		# No projectile in range, skip
		return

	for projectile in projectiles_in_range:
		deflect_projectile(projectile)

func deflect_projectile(projectile: RigidBody2D) -> void:
	# Mark projectile as parried if you have that logic in your projectile script
	projectile.parried = true

	# Adjust collision layers to avoid colliding with the player
	# Turn OFF player layer/mask (assuming layer/mask 1 is the player)
	projectile.set_collision_layer_value(1, false)
	projectile.set_collision_mask_value(1, false)
	
	# Turn ON mob layer/mask (assuming layer/mask 3 is the mobs)
	projectile.set_collision_layer_value(3, true)
	projectile.set_collision_mask_value(3, true)

	# Calculate the shield's facing direction:
	# In local space, "facing right" is Vector2.RIGHT. 
	# We rotate it by the shield's current rotation to get the global forward direction.
	var shield_facing_direction = Vector2.RIGHT.rotated(rotation)

	var original_speed = projectile.linear_velocity.length()
	var new_speed = original_speed * 10.0  

	# Assign new velocity so the projectile flies in the shield's forward direction
	projectile.linear_velocity = shield_facing_direction * new_speed
