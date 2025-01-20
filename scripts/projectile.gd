extends RigidBody2D

func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	# Optionally, you can control velocity here if not set externally:
	# linear_velocity = Vector2(projectile_speed, 0) 
	# or you might have already assigned linear_velocity in another script method
	pass

func _on_body_entered(body: Node) -> void:
	# Check if we collided with the player named "Idiot_hero"
	if body.name == "Idiot_hero":
		print("Projectile hit the player! Game over!")
		get_tree().change_scene_to_file("res://scenes/menu/game_over.tscn")
	
