extends CharacterBody2D

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
