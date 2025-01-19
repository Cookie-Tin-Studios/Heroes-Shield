extends CharacterBody2D

@export var speed: float = 100.0

func _physics_process(delta: float) -> void:
	# Move the NPC to the right at 'speed' pixels per second
	position.x += speed * delta
