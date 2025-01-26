extends "res://scripts/mobs/mob_base.gd"

# Determines how far above (or below) the collision shape the health bar should appear.
@export var health_bar_offset: Vector2 = Vector2(0, -20)
@export var health_bar_follow_collision: bool = true

@onready var global_tick = get_node("/root/Tick")  # For attack cooldowns
@onready var attackbox = $attackbox  # Area2D for detecting attack range
@onready var animated_sprite = $AnimatedSprite2D  # Reference to the AnimatedSprite2D node
@onready var parry_sprite = $attackbox/parry_sprite  # Reference to the AnimatedSprite2D node

@export var chase_speed: float = 250.0
@export var shield_range: float = 400.0  # Distance to prioritize the shield
@export var melee_range: float = 1.0  # Attack range (update if needed)
@export var attack_damage: int = 1  # Damage dealt per attack
@export var attack_cooldown: float = 1.0  # Time between attacks
@export var parry_window_duration: float = 0.5  # Time window for parry

var current_state: String = "CHASE"
var target: Node2D = null  # The current target (hero or shield)
var shield: Node2D = null  # The shield node
var last_attack_time: float = 0.0  # Tracks time of the last attack
var is_attacking: bool = false  # Prevents overlapping attacks
var is_in_parry_window: bool = false  # Tracks if the mob is vulnerable to parry

func _ready() -> void:
	super._ready()
	_update_target_priority()

	# Connect to shield parry signal
	if is_instance_valid(shield):
		shield.connect("attempt_parry", Callable(self, "_on_parry_attempted"))
	else:
		print("Shield not found in the scene!")

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if not is_instance_valid(target):
		_update_target_priority()
		return

	# Calculate distances to target and shield
	var distance_to_target = global_position.distance_to(target.global_position) if is_instance_valid(target) else INF
	var distance_to_shield = global_position.distance_to(shield.global_position) if is_instance_valid(shield) else INF

	# Determine if the shield is between the mob and the hero
	var shield_in_path = is_shield_in_path()

	# State transitions
	if is_instance_valid(shield) and shield_in_path and distance_to_shield <= shield_range:
		current_state = "ENGAGE_SHIELD"
	elif distance_to_target <= melee_range:
		current_state = "ENGAGE_TARGET"
	else:
		current_state = "CHASE"

	# Handle states
	match current_state:
		"CHASE":
			_move_toward(target.global_position, delta)

		"ENGAGE_TARGET":
			perform_attack(target)

		"ENGAGE_SHIELD":
			perform_attack(shield)
			
	# Ensure the health bar follows the collision shape's position if available
	if collision_shape:
		$Node2D.position = collision_shape.global_position + Vector2(0, -20)  # Adjust offset as needed
	else:
		print("CollisionShape2D not found!")

func _move_toward(point: Vector2, delta: float) -> void:
	if is_attacking:
		return  # Don't move while attacking

	var direction = (point - global_position).normalized()
	position += direction * chase_speed * delta

	# Play the walking animation
	if animated_sprite and not is_attacking:
		animated_sprite.play("walk")  # Ensure "walk" is the walking animation's name

func perform_attack(victim: Node) -> void:
	if is_attacking or Time.get_ticks_msec() - last_attack_time < attack_cooldown * 1000:
		return  # Prevent multiple attacks at once or if cooldown is active

	is_attacking = true
	last_attack_time = Time.get_ticks_msec()

	# Step 1: Play the attack animation
	if animated_sprite:
		animated_sprite.play("attack")  # Ensure "attack" is the attack animation's name

	# Step 2: Activate the parry window
	is_in_parry_window = true
	print("Parry window started.")
	parry_sprite.play("parryable")
	await get_tree().create_timer(parry_window_duration).timeout
	parry_sprite.stop()
	is_in_parry_window = false
	print("Parry window ended.")

	# Step 3: Deal damage if not interrupted by a parry
	if is_instance_valid(victim):
		_deal_damage(victim)

	# Step 4: Reset state after attack
	is_attacking = false
	if animated_sprite:
		animated_sprite.play("walk")  # Return to walking animation

func _on_parry_attempted(mob: Node) -> void:
	if mob != self:
		return  # Ignore parry attempts for other mobs

	print("Parry attempt detected for: ", name)
	if is_in_parry_window == true:
		parry(attack_damage)  # Pass the attack damage to the parry function
	else:
		print("Parry failed! Mob is not in the parry window.")

# 
func parry(damage: float) -> void:
	print("Mob parried! Taking ", damage, " damage.")
	if has_method("take_damage") and is_in_parry_window == true:
		take_damage(damage)  # Apply damage to the mob with the provided damage value
	else:
		print("Mob not parryable or missing take_damage method.")
	is_attacking = false
	is_in_parry_window = false


func _deal_damage(victim: Node) -> void:
	if victim.has_method("take_damage"):
		victim.take_damage(attack_damage)
		print("Dealt ", attack_damage, " damage to ", victim.name)
	else:
		print("No 'take_damage' method found on: ", victim)

func _on_attackbox_body_entered(body: Node) -> void:
	if body == target or body == shield:
		perform_attack(body)

func _update_target_priority() -> void:
	# Try to set the shield as the first priority
	shield = get_tree().get_current_scene().get_node_or_null("Shield")
	if is_instance_valid(shield):
		print("Shield detected!")

	# Default to the hero (Idiot) if no shield is valid
	target = get_tree().get_current_scene().get_node_or_null("Idiot_hero")
	if is_instance_valid(target):
		print("Targeting Idiot_hero!")
	else:
		print("No valid target found!")

func is_shield_in_path() -> bool:
	# Check if the shield is between the mob and the hero
	if not is_instance_valid(shield) or not is_instance_valid(target):
		return false

	var mob_to_target = target.global_position - global_position
	var mob_to_shield = shield.global_position - global_position

	# Check if the shield is closer than the target and along the same path
	return mob_to_shield.length() < mob_to_target.length() and mob_to_shield.normalized().dot(mob_to_target.normalized()) > 0.9
