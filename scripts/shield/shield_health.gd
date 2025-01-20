extends CharacterBody2D 

# Health variable
@export var max_health: int = 3
var current_health: int

func _ready():
	# Initialize health
	current_health = max_health
	$ParryArea.body_entered.connect(_on_parry_area_body_entered) # parrymech
	$ParryArea.body_exited.connect(_on_parry_area_body_exited) # parrymech

# Function to take damage
func take_damage(amount: int):
	current_health -= amount

	if current_health <= 0:
		die()

# Function called when health reaches 0
func die():
	print("Character has died!")
	queue_free()  # Remove the character from the scene


# Speed of movement
@export var speed: float = 400

func _process(delta: float) -> void:
	var direction = Vector2.ZERO

	# Up and Down movement
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		direction.x += 1

	# Apply movement
	velocity = direction.normalized() * speed
	move_and_slide()

	# Restrict the character to stay within the camera's visible bounds
	restrict_to_camera()
	
	# Parry attempt parry if input pressed. parrymech
	if Input.is_action_just_pressed("parry"):
		attempt_parry()

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

func attempt_parry() -> void:
	if projectiles_in_range.size() == 0:
		# No projectile in range, don't bother parrying.
		return

	# Reflect every projectile in range.
	for projectile in projectiles_in_range:
		deflect_projectile(projectile)
		
func deflect_projectile(projectile: RigidBody2D) -> void:
	# Just reverse velocity for now. 
	# Eventually, we should make it such that parried projectiles fly straight away from the center of the sheild.
	projectile.linear_velocity = -projectile.linear_velocity
	# Make it fast as fuck, for the fans. 
	projectile.linear_velocity *= 10  
