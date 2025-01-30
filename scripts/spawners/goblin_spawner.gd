extends Area2D

@export var mob_scene: PackedScene = preload("res://scenes/goblin.tscn")
@export var spawn_interval: float = 2.0

var spawned_mobs: Array = []

func _ready() -> void:
	randomize()
	spawn_mob_timer()

func spawn_mob_timer() -> void:
	while true:
		await get_tree().create_timer(spawn_interval).timeout
		spawn_mob()

func spawn_mob() -> void:
	if not mob_scene:
		push_warning("No mob_scene assigned in spawner.")
		return
	if spawned_mobs.size() >= Globals.goblin_max_mobs:
		return

	var mob_instance = mob_scene.instantiate()
	
	# Instead of 'add_child', add to the main scene:
	var main_scene = get_tree().get_current_scene()
	main_scene.add_child(mob_instance)

	# Randomize spawn position within the spawner’s CollisionShape2D (if present)
	if $CollisionShape2D and $CollisionShape2D.shape:
		var shape_extents = $CollisionShape2D.shape.extents
		var random_offset = Vector2(
			randf_range(-shape_extents.x, shape_extents.x),
			randf_range(-shape_extents.y, shape_extents.y)
		)
		# Use the spawner’s global position plus the random offset
		mob_instance.global_position = global_position + random_offset
	else:
		# Fallback if no shape:
		mob_instance.global_position = global_position

	spawned_mobs.append(mob_instance)

	# Bind the mob_instance reference so we know which one exited
	mob_instance.connect("tree_exited", Callable(self, "_on_mob_removed").bind(mob_instance))

func _on_mob_removed(mob_instance: Node) -> void:
	if mob_instance in spawned_mobs:
		spawned_mobs.erase(mob_instance)
