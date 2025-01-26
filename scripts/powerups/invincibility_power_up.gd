extends Area2D

@export var duration: float = 10.0
@export var movement_speed: float = -300.0

func _ready() -> void:
	pass

func _on_movement_powerup_body_entered(body: Node) -> void:
	if body is CharacterBody2D:
		# Safely check if the body has a method to apply speed boost.
		if body.has_method("apply_invincibility"):
			body.apply_invincibility(duration)
					
		queue_free()

func _physics_process(delta: float) -> void:
	position.x += movement_speed * delta
