extends "res://scripts/mobs/mob_base.gd"

@onready var attackbox = $CollisionShape2D2 # Area2D for detecting attack range
@onready var animated_sprite = $AnimatedSprite2D  # Reference to the AnimatedSprite2D node

@export var chase_speed: float = 250.0
@export var attack_damage: int = 1  # Damage dealt per attack
@export var attack_cooldown: float = 1.0  # Time between attacks
@export var parry_window_duration: float = 0.5  # Time window for parry

var target: Node2D = null  # The current target
var last_attack_time: float = 0.0  # Tracks time of the last attack
var is_attacking: bool = false  # Prevents overlapping attacks
var is_in_parry_window: bool = false  # Tracks if the mob is vulnerable to parry

func _ready() -> void:
	# Connect signals for attackbox
	if attackbox:
		attackbox.connect("body_entered", Callable(self, "_on_attackbox_body_entered"))
	else:
		print("Warning: attackbox not found!")

func _physics_process(delta: float) -> void:
	if is_attacking:
		return  # Don't move while attacking

	if is_instance_valid(target):
		_move_toward_target(delta)
	else:
		_update_target()

# Move toward the target
func _move_toward_target(delta: float) -> void:
	var direction = (target.global_position - global_position).normalized()
	position += direction * chase_speed * delta

	# Play walking animation
	if animated_sprite and not is_attacking:
		animated_sprite.play("walk")

# Perform an attack
func perform_attack(victim: Node) -> void:
	if is_attacking or Time.get_ticks_msec() - last_attack_time < attack_cooldown * 1000:
		return  # Prevent multiple attacks during cooldown

	is_attacking = true
	last_attack_time = Time.get_ticks_msec()

	# Step 1: Play attack animation
	if animated_sprite:
		animated_sprite.play("attack")
	print("Attacking ", victim.name)

	# Step 2: Start the parry window
	is_in_parry_window = true
	print("Parry window started.")
	await get_tree().create_timer(parry_window_duration).timeout
	print("Parry window ended.")
	is_in_parry_window = false

	# Step 3: Deal damage if not parried
	_deal_damage(victim)

	# Step 4: Reset state after attack
	is_attacking = false
	if animated_sprite:
		animated_sprite.play("walk")

# Handle parry logic when shield calls `attempt_melee_parry`
func parry(damage: float) -> void:
	print("Mob parried! Taking ", damage, " damage.")
	if has_method("take_damage"):
		take_damage(damage)  # Apply damage to the mob
	is_attacking = false
	is_in_parry_window = false

# Deal damage to the victim
func _deal_damage(victim: Node) -> void:
	if victim.has_method("take_damage"):
		victim.take_damage(attack_damage)
		print("Dealt ", attack_damage, " damage to ", victim.name)
	else:
		print("No 'take_damage' method on: ", victim)

# Handle attackbox collision detection
func _on_attackbox_body_entered(body: Node) -> void:
	if body.is_in_group("dmg"):  # Ensure the body is in the "dmg" group
		print("Attackbox collided with: ", body.name)
		perform_attack(body)

# Update the target to the shield or its damage zone
func _update_target() -> void:
	var shield_node = get_tree().get_current_scene().get_node_or_null("Shield")
	if is_instance_valid(shield_node):
		target = shield_node
		print("Targeting Shield!")
	else:
		print("Shield not detected.")
