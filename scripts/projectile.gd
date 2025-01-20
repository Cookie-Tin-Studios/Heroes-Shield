extends RigidBody2D

func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	# Optionally, you can control velocity here if not set externally:
	# linear_velocity = Vector2(projectile_speed, 0) 
	# or you might have already assigned linear_velocity in another script method
	pass

# Collision detection logic.
# Only handles collisions with the idiot. Will need to be updated later to handle sheild collision.
func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D:
		# Both the sheild and the idiot are CharachterBody2D.
		# This makes it so the game over only happens for idiot hits.
		if body.name == "Idiot_hero":
			# Game over. Just goes to the main menu for now.
			get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
			# queue_free would remove the projectile if needed.
			# I don't THINK we need this, since a hit is instant death. But if we
			# decided against that later maybe with a powerup or something, it's here lol.
			#queue_free()

	
