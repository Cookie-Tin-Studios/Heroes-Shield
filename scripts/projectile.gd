extends RigidBody2D

@export var damage: int = 1  # Damage dealt by the projectile

func _ready() -> void:
	# Called when the projectile is added to the scene.
	# Currently, no specific initialization is needed.
	pass

func _physics_process(_delta: float) -> void:
	# This function runs every frame. If movement is not handled externally,
	# you can set the projectile's velocity here (e.g., linear_velocity).
	pass

# Handles collision detection and damage application.
func _on_body_entered(body: Node) -> void:
	# Check if the collided body is a CharacterBody2D (e.g., Idiot_hero or Shield).
	if body is CharacterBody2D:
		# If the collided body has a take_damage method, deal damage to it.
		if body.has_method("take_damage"):
			body.take_damage(damage)  # Apply damage to the target.
			print("Projectile hit ", body.name, " for ", damage, " damage.")
		
		# Remove the projectile after it hits any target.
		queue_free()
