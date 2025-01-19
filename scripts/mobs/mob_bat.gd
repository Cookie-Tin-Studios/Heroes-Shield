extends RigidBody2D


@export var projectile_scene: PackedScene
@export var shooting_speed: float = 1000.0
@export var target: CharacterBody2D

func shoot_projectile() -> void:
	if not target:
		return  # No target assigned

	# 1. Instantiate the projectile
	var projectile = projectile_scene.instantiate()

	# 2. Position the projectile at the shooter's position (or a "muzzle" offset)
	#    If you have a specific node like a "Muzzle" Node2D, use muzzle.global_position instead.
	projectile.global_position = global_position  

	# 3. Calculate the direction toward the target
	var direction = (target.global_position - global_position).normalized()

	# 4. Assign velocity or force depending on projectile type

	## If the projectile is an Area2D (moved by code):
	#if projectile is Area2D:
		## We'll store or set a velocity variable and move it in the projectile's _physics_process.
		## e.g., projectile.velocity = direction * shooting_speed 
		## This depends on how you code the projectile scene.  
#
		## Alternatively, you can add a script to the projectile for immediate impulse:
		#if projectile.has_method("init_projectile"):
			#projectile.init_projectile(direction * shooting_speed)
	
	# If the projectile is a RigidBody2D:
	if projectile is RigidBody2D:
		projectile.linear_velocity = direction * shooting_speed

	# 5. Add the projectile to the scene tree
	get_tree().get_current_scene().add_child(projectile)






# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Example: shoot a projectile every second
	# (simple logic, you could use a Timer node, or more advanced AI conditions)
	shoot_projectile()
	#pass
	
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
