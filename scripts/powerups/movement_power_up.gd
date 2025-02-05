extends Area2D

@export var speed_boost_factor: float = 2.5
@export var duration: float = 10.0
@export var movement_speed: float = -100.0


func _ready() -> void:
	pass

func _on_movement_powerup_body_entered(body: Node) -> void:
	print("body entered")
	if body is CharacterBody2D:
		print("chracter body entered")
		# Safely check if the body has a method to apply speed boost.
		if body.has_method("apply_speed_boost"):
			body.apply_speed_boost(speed_boost_factor, duration)
					
		# Remove the powerup from the scene once picked up
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
