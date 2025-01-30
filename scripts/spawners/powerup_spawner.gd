extends Area2D

@export var invincibilityPowerUp: PackedScene = preload("res://scenes/powerups/invincibility_power_up.tscn")
@export var speedPowerUp: PackedScene = preload("res://scenes/powerups/movement_power_up.tscn")
@export var healthPowerUp: PackedScene = preload("res://scenes/powerups/health_power_up.tscn")
@export var spawn_interval: float = 10.0
@export var max_power_ups: int = 2

var spawned_power_ups: Array = []

func _ready() -> void:
	randomize()
	spawn_mob_timer()

func spawn_mob_timer() -> void:
	while true:
		await get_tree().create_timer(spawn_interval).timeout
		var powerUpNum = randi_range(0,2)
		spawn_mob(powerUpNum)

func spawn_mob(powerUpNum: int) -> void:
	if not speedPowerUp:
		push_warning("No mob_scene assigned in spawner.")
		return
		
	if not invincibilityPowerUp:
		push_warning("No mob_scene assigned in spawner.")
		return
		
	if not healthPowerUp:
		push_warning("No mob_scene assigned in spawner.")
		return
		
	if spawned_power_ups.size() >= max_power_ups:
		return
		

	var power_up_instance
	match powerUpNum:
		0:
			power_up_instance = invincibilityPowerUp.instantiate()
		1:
			power_up_instance = speedPowerUp.instantiate()
		2:
			power_up_instance = healthPowerUp.instantiate()
	
	# Instead of 'add_child', add to the main scene:
	var main_scene = get_tree().get_current_scene()
	main_scene.add_child(power_up_instance)

	# Randomize spawn position within the spawner’s CollisionShape2D (if present)
	if $CollisionShape2D and $CollisionShape2D.shape:
		var shape_extents = $CollisionShape2D.shape.extents
		var random_offset = Vector2(
			randf_range(-shape_extents.x, shape_extents.x),
			randf_range(-shape_extents.y, shape_extents.y)
		)
		# Use the spawner’s global position plus the random offset
		power_up_instance.global_position = global_position + random_offset
	else:
		# Fallback if no shape:
		power_up_instance.global_position = global_position

	spawned_power_ups.append(power_up_instance)

	# Bind the mob_instance reference so we know which one exited
	power_up_instance.connect("tree_exited", Callable(self, "_on_power_up_removed").bind(power_up_instance))

func _on_power_up_removed(mob_instance: Node) -> void:
	if mob_instance in spawned_power_ups:
		spawned_power_ups.erase(mob_instance)
