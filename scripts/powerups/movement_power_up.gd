extends Area2D

@export var speed_boost_factor: float = 2.5
@export var duration: float = 10.0
@export var movement_speed: float = -100.0


func _ready() -> void:
	pass

func _on_movement_powerup_body_entered(body: Node) -> void:
	print("body entered")
	if body is CharacterBody2D:
		print("chracter body entered")
		# Safely check if the body has a method to apply speed boost.
		if body.has_method("apply_speed_boost"):
			body.apply_speed_boost(speed_boost_factor, duration)
					
		# Remove the powerup from the scene once picked up
		queue_free()

func _physics_process(delta: float) -> void:
	position.x += movement_speed * delta
