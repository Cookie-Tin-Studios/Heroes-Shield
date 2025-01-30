extends RigidBody2D

@export var attack_damage: int = 1
@export var attack_range: float = 100.0
@export var attack_cooldown: float = 1.0
@export var parry_window: float = 1.0

var is_attacking = false
var is_parried = false
var entities_in_attack_area: Array[Node] = []  # Track entities in the attack area
var is_on_cooldown = false  # Track if the goblin is on cooldown

@onready var parry_timer: Timer = $ParryTimer
@onready var attack_timer: Timer = $AttackTimer
@onready var animations = $AnimatedSprite2D

@export var movement_speed: float = -100.0
@export var max_health: float = 1
var health: float = max_health  # Current health

@export var coins_dropped: int = 10

@onready var health_bar = $HealthBar/TextureProgressBar

func _ready() -> void:
	# Initialize the health bar if it exists
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health
	else:
		print("Health bar not found!")

	# Connect the attack timer's timeout signal
	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = true
	attack_timer.timeout.connect(_on_attack_cooldown_end)

func _physics_process(delta: float) -> void:
	var idiot_hero = get_node("../Idiot_hero")

	# If there are entities in the attack area, behave differently
	if entities_in_attack_area.size() > 0:
		if not is_attacking and not is_on_cooldown:
			# Start an attack if not already attacking and not on cooldown
			start_attack(entities_in_attack_area[0])
		elif is_on_cooldown:
			# If on cooldown, use the same movement as when attacking
			if idiot_hero:
				linear_velocity = idiot_hero.velocity
			else:
				print("Shield: Hero path is not set!")
			# Play the "idle" animation
			animations.play("idle")
	else:
		# If no entities in the attack area, move left
		if not is_attacking:
			linear_velocity.x = movement_speed
			animations.play("walk")

func _on_attack_area_body_entered(body: Node) -> void:
	print("body entered: ", body.name)
	if body.is_in_group("good_guys"):
		entities_in_attack_area.append(body)  # Add the entity to the list

func _on_attack_area_body_exited(body: Node) -> void:
	print("body exited: ", body.name)
	if body in entities_in_attack_area:
		entities_in_attack_area.erase(body)  # Remove the entity from the list

func start_attack(target: Node) -> void:
	is_attacking = true
	is_parried = false
	parry_timer.start()
	animations.play("attack")
	# After some delay, actually deal damage if not parried
	await parry_timer.timeout
	if !is_parried:
		print("attacked: ", target)
		# If shield parry didn't happen yet, damage the target
		if target.has_method("take_damage"):
			target.take_damage(attack_damage)
		# Recoil
		position.x += 30
	is_attacking = false
	animations.play("walk")  # Switch back to walk animation

	# Start the attack cooldown
	is_on_cooldown = true
	attack_timer.start()

func _on_parry_window_end() -> void:
	# If parry window ends without parry, no longer parryable
	is_parried = false

func _on_attack_cooldown_end() -> void:
	# Cooldown finished, ready to attack again
	is_on_cooldown = false

func take_damage(amount: float) -> void:
	health = max(health - amount, 0)
	update_health_bar()

	if health <= 0:
		die()
		
func coin_explosion() -> void:
	for i in range(coins_dropped):
		var coin_sprite := preload("res://scenes/coin.tscn").instantiate()
		coin_sprite.global_position = self.global_position
				
		add_sibling(coin_sprite)
		# give some initial velocity in a random direction to make it "explode"
		coin_sprite.linear_velocity = Vector2(8000, 0).rotated(randf_range(0.0, TAU))
		coin_sprite.despawn.connect(func(): Globals.add_coins(1))
	

func remon_on_camera_exit() -> void:
	# Get the active Camera2D
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return
	
	# Calculate the camera's visible area in world coordinates
	var camera_rect = Rect2(camera.global_position - (get_viewport_rect().size / 2) / camera.zoom, get_viewport_rect().size / camera.zoom)

	# Clamp the character's position within the camera's visible area
	if position.x < camera_rect.position.x:
		queue_free()

func update_health_bar() -> void:
	if health_bar:
		health_bar.value = health
	else:
		print("Health bar not found!")

func die() -> void:
	print("Mob has died!")
	coin_explosion()
	
	#Globals.add_coins(coins_dropped) # Give the player however COINZ.
	queue_free()  # Remove mob from the scene
