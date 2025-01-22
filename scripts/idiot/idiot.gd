extends CharacterBody2D

@export var speed: float = 100.0

# We'll store the character's starting X position so we can measure total distance traveled
var start_x: float = 0.0

func _ready() -> void:
	# Capture the initial X position when the scene starts
	start_x = position.x

func _physics_process(delta: float) -> void:
	# Move the character to the right at 'speed' pixels per second
	position.x += speed * delta

	# Calculate how far this character has moved from its original position
	var distance_traveled = position.x - start_x

	# Just in case the position could somehow be less than its start,
	# clamp distance to never go below 0
	if distance_traveled < 0:
		distance_traveled = 0

	# Update the global progress to reflect the traveled distance
	Globals.level_progress = int(distance_traveled)

# Function to take damage
func take_damage(_amount: int) -> void:
	print("Idiot_hero took damage! Game Over!")
	# Change to the game over scene
	get_tree().change_scene_to_file("res://scenes/menu/game_over.tscn")
