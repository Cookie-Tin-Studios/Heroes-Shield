extends "res://scripts/mobs/mob_base.gd"

@onready var global_tick = get_node("/root/Tick")
@onready var attackbox = $mob_attackbox

@export var chase_speed: float = 400.0
@export var melee_range: float = 600.0
@export var shield_range: float = 500.0

var current_state: String = "CHASE"
var target: Node2D = null
var shield: Node2D = null

func _ready() -> void:
	super._ready()
	# Attempt to find targets
	_update_target_priority()
	# Connect attackbox signal
	attackbox.connect("body_entered", Callable(self, "_on_attackbox_body_entered"))

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if not is_instance_valid(target) and not is_instance_valid(shield):
		_update_target_priority()
		return

	var distance_to_target = INF
	var distance_to_shield = INF

	if is_instance_valid(target):
		distance_to_target = global_position.distance_to(target.global_position)
	if is_instance_valid(shield):
		distance_to_shield = global_position.distance_to(shield.global_position)

	if distance_to_shield <= shield_range and distance_to_shield < distance_to_target:
		current_state = "ENGAGE_SHIELD"
	elif distance_to_target <= melee_range:
		current_state = "ENGAGE_TARGET"
	else:
		current_state = "CHASE"

	match current_state:
		"CHASE":
			print("Chasing target...")
			if is_instance_valid(target):
				_move_toward(target.global_position, delta)

		"ENGAGE_TARGET":
			print("Engaging target!")
			_engage_target()

		"ENGAGE_SHIELD":
			print("Engaging shield!")
			_engage_shield()

func _move_toward(point: Vector2, delta: float) -> void:
	var direction = (point - global_position).normalized()
	position += direction * chase_speed * delta

func _engage_target() -> void:
	if is_instance_valid(target):
		_perform_melee_attack(target)

func _engage_shield() -> void:
	if is_instance_valid(shield):
		_perform_melee_attack(shield)

func _perform_melee_attack(victim: Node) -> void:
	if victim == target:
		print("Attacked: ", victim.name)

func _update_target_priority() -> void:
	if is_instance_valid(shield):
		print("Targeting shield!")
		target = shield
		return

	var found_target = get_tree().get_current_scene().get_node_or_null("Idiot_hero")
	if found_target and found_target is CharacterBody2D:
		target = found_target
		print("Targeting Idiot_hero!")
	else:
		print("No valid target found!")

func _on_attackbox_body_entered(body: Node) -> void:
	if body == target:
		print("Target is within melee range!")
		_perform_melee_attack(target)
