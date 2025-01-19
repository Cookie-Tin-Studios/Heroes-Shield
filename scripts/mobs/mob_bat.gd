extends RigidBody2D

@onready var global_tick = get_node("/root/Tick")
@export var projectile_scene: PackedScene
@export var shooting_speed: float = 500.0
@export var target: CharacterBody2D

func shoot_projectile() -> void:
	# If there is no target, don't shoot anything.
	if not target:
		return
	# If there is a target, proceed with the rest of the function.
	
	# Take the Projectile scene and bring it into 
	var projectile = projectile_scene.instantiate()

	# Give the projectile the inital position (same as bat)
	projectile.global_position = global_position

	# Make projectile target NPC Hero
	var direction = (target.global_position - global_position).normalized()

	
	# Assign velocity to projectile
	if projectile is RigidBody2D:
		projectile.linear_velocity = direction * shooting_speed

	# Add projectile to scene.
	get_tree().get_current_scene().add_child(projectile)



func _on_tick():
	shoot_projectile()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_tick.timeout.connect(_on_tick)
	pass # Replace with function body.

# Not required, we're using physics process instead.
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
	
@export var movement_speed: float = -100.0

func _physics_process(delta: float) -> void:
	# Move the NPC to the right at 'speed' pixels per second
	position.x += movement_speed * delta
