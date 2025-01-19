extends CharacterBody2D 

# Health variable
@export var max_health: int = 3
var current_health: int

func _ready():
	# Initialize health
	current_health = max_health

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
