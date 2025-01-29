extends RigidBody2D

@export var damage: int = 1
@export var parried: bool = false
@export var shooter: RigidBody2D

var zigzag_enabled: bool = false
var homing_enabled: bool = false

# ZigZag parameters
var zigzag_angle: float = 0.0
@export var zigzag_frequency: float = 15.0   # How quickly it oscillates
@export var zigzag_amplitude: float = 1000.0   # How wide the zigzag is
@export var initial_direction: Vector2 = Vector2.ZERO
@export var base_speed: float = 0.0

# Homing parameters
@export var homing_speed: float = 500.0      # Base speed for homing
@export var homing_strength: float = 0.1     # Interpolation factor for turning toward target

# Ziggin parameters
var zig_side = 1
var zig_period = 0.25  # seconds per flip
var timer = 0.0
# Explosion parameters
var exploding: bool = false
var explosion_lines: int = 12  # Number of lines to draw for the explosion
var explosion_length: float = 50.0  # Length of the explosion lines
var explosion_duration: float = 0.2  # Duration of the explosion effect
var explosion_timer: float = 0.0

@onready var main_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Reference to the child Node2D for drawing
@onready var explosion_drawer: Node2D = $ExplosionDrawer

func _ready() -> void:
	# Ensure the explosion drawer is initially hidden
	explosion_drawer.visible = false

func _physics_process(delta: float) -> void:
	if parried:
		# If homing is enabled, steer toward nearest enemy
		if homing_enabled:
			apply_homing(delta)

		# If zigzag is enabled, apply zigzag offset
		if zigzag_enabled:
			apply_zigzag(delta)

	# Handle explosion timer
	if exploding:
		explosion_timer -= delta
		if explosion_timer <= 0:
			queue_free()  # Remove the projectile after the explosion is done
		explosion_drawer.queue_redraw()  # Redraw the explosion lines

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D or body is RigidBody2D:
		if body.has_method("take_damage"):
			body.take_damage(damage)
			print("Projectile hit ", body.name, " for ", damage, " damage.")
			explode()
			
		if body.has_method("when_hit"):
			body.when_hit()  # Apply damage to the target.
			print("when_hit function ran.")
			explode()

	# Check if the collided body is a parried projectile
	if body is RigidBody2D and body.has_method("is_parried") and body.is_parried():
		explode()
		if body.has_method("explode"):
			body.explode()

func apply_homing(delta: float) -> void:
	print("homing applied")
	# Attempt to find the nearest enemy (mob) in the scene
	var nearest_enemy := find_nearest_enemy()
	if nearest_enemy == null:
		return

	var direction = (nearest_enemy.global_position - global_position).normalized()
	var desired_velocity = direction * homing_speed
	# Lerp from current velocity to the new desired velocity, to get a smooth turn
	linear_velocity = linear_velocity.lerp(desired_velocity, homing_strength)

func apply_zigzag(delta: float) -> void:
	timer += delta
	if timer >= zig_period:
		timer = 0.0
		zig_side *= -1  # flip from +1 to -1 or vice versa

	# Build velocity from that flip
	var forward_dir = initial_direction
	var perpendicular_dir = forward_dir.rotated(PI / 2)
	# amplitude is how far we move sideways
	linear_velocity = forward_dir * base_speed + perpendicular_dir * (zig_side * zigzag_amplitude)

func find_nearest_enemy() -> Node2D:
	var nearest_dist = INF
	var nearest_enemy: Node2D = null

	# This assumes enemies are in the group "mobs"
	for enemy in get_tree().get_nodes_in_group("mobs"):
		if not enemy is Node2D:
			continue

		var dist = global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest_enemy = enemy

	return nearest_enemy

func is_parried() -> bool:
	return parried

func explode() -> void:
	if not exploding:  # Ensure explosion only happens once
		exploding = true
		explosion_timer = explosion_duration
		main_sprite.visible = false  # Hide the main sprite
		explosion_drawer.visible = true  # Make the explosion drawer visible
		explosion_drawer.queue_redraw()  # Trigger the drawing of explosion lines
