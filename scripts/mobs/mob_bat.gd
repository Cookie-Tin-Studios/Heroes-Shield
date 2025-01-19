extends RigidBody2D

@onready var global_tick = get_node("/root/Tick")
@export var projectile_scene: PackedScene
@export var shooting_speed: float = 1000.0
@export var target: CharacterBody2D

func shoot_projectile() -> void:
	# If there is no target, don't shoot anything.
	if not target:
		return
	# If there is a target, proceed with the rest of the function.
	
	# Take the Projectile scene and bring it into 
	var projectile = projectile_scene.instantiate()

	# Give the projectile the inital 
	projectile.global_position = global_position  

	# 3. Calculate the direction toward the target
	var direction = (target.global_position - global_position).normalized()

	# 4. Assign velocity or force depending on projectile type
	
	# If the projectile is a RigidBody2D:
	if projectile is RigidBody2D:
		projectile.linear_velocity = direction * shooting_speed

	# 5. Add the projectile to the scene tree
	get_tree().get_current_scene().add_child(projectile)



func _on_tick():
	shoot_projectile()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_tick.timeout.connect(_on_tick)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Example: shoot a projectile every second
	# (simple logic, you could use a Timer node, or more advanced AI conditions)
	pass
	
@export var movement_speed: float = -100.0

func _physics_process(delta: float) -> void:
	# Move the NPC to the right at 'speed' pixels per second
	position.x += movement_speed * delta
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
