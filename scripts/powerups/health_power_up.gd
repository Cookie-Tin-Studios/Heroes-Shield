extends Area2D

@export var amount: float = 1.0
@export var movement_speed: float = -300.0



func _ready() -> void:
	pass

func _on_movement_powerup_body_entered(body: Node) -> void:
	if body is CharacterBody2D:
		print("shield picked up some health")
		# Safely check if the body has a method to apply speed boost.
		if body.has_method("apply_healing"):
			print("applying healing", amount)
			body.apply_healing(amount)
		
		queue_free()

func _physics_process(delta: float) -> void:
	position.x += movement_speed * delta
