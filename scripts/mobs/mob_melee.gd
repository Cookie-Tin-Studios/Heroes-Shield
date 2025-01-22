extends "res://scripts/mobs/mob_base.gd"

@onready var global_tick = get_node("/root/Tick")  # For attack cooldowns
@onready var attackbox = $mob_attackbox  # Area2D for detecting attack range
@onready var animated_sprite = $AnimatedSprite2D  # Reference to the AnimatedSprite2D node

@export var chase_speed: float = 250.0
@export var shield_range: float = 500.0  # Distance to prioritize the shield
@export var melee_range: float = 1.0  # Attack range (update if needed)
@export var attack_damage: int = 1  # Damage dealt per attack
@export var attack_cooldown: float = 1.0  # Time between attacks

var current_state: String = "CHASE"
var target: Node2D = null  # The current target (hero or shield)
var shield: Node2D = null  # The shield node
var last_attack_time: float = 0.0  # Tracks time of the last attack
var is_attacking: bool = false  # Prevents overlapping attacks

func _ready() -> void:
	super._ready()
	_update_target_priority()

	# Connect signals
	if attackbox:
		attackbox.connect("body_entered", Callable(self, "_on_attackbox_body_entered"))
	else:
		print("Warning: mob_attackbox not found!")

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
			if is_instance_valid(target):
				_move_toward(target.global_position, delta)

		"ENGAGE_TARGET":
			if is_instance_valid(target):
				perform_attack(target)

		"ENGAGE_SHIELD":
			if is_instance_valid(shield):
				perform_attack(shield)

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

	# Play the attack animation
	if animated_sprite:
		animated_sprite.play("attack")  # Ensure "attack" is the attack animation's name

	# Schedule the damage application at the end of the animation
	await attack_animation_delay()  # Wait for the animation to finish
	_deal_damage(victim)

	# Reset state after attack
	is_attacking = false
	if animated_sprite:
		animated_sprite.play("walk")  # Return to walking animation

func attack_animation_delay() -> void:
	# Simulate the attack animation duration; adjust as needed
	await get_tree().create_timer(0.5).timeout  # Replace 0.5 with your actual animation duration

func _deal_damage(victim: Node) -> void:
	if victim and victim.has_method("take_damage"):
		victim.take_damage(attack_damage)
		print("Attacked ", victim.name, " for ", attack_damage, " damage!")
	else:
		print("No 'take_damage()' method found on: ", victim)

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
