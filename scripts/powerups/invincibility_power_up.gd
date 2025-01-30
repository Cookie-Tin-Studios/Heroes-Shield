extends Area2D

@export var duration: float = 10.0
@export var movement_speed: float = -300.0

func _ready() -> void:
	pass

func _on_movement_powerup_body_entered(body: Node) -> void:
	if body is CharacterBody2D:
		# Safely check if the body has a method to apply speed boost.
		if body.has_method("apply_invincibility"):
			body.apply_invincibility(duration)
					
		queue_free()

func _physics_process(delta: float) -> void:
	position.x += movement_speed * delta
	remove_on_camera_exit()
	

func remove_on_camera_exit() -> void:
	# Get the active Camera2D
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return
	
	# Calculate the camera's visible area in world coordinates
	var camera_rect = Rect2(camera.global_position - (get_viewport_rect().size / 2) / camera.zoom, get_viewport_rect().size / camera.zoom)

	# Clamp the character's position within the camera's visible area
	if position.x < camera_rect.position.x:
		queue_free()
