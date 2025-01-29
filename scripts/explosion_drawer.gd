extends Node2D

# Explosion parameters (passed from the parent projectile)
var explosion_lines: int = 12
var explosion_length: float = 50.0
var explosion_timer: float = 0.2  # Duration of the explosion effect

func _draw() -> void:
	# Calculate the alpha (transparency) based on the explosion timer
	var alpha = explosion_timer / 0.2  # Fade out over the explosion duration
	var color = Color(0, 1, 0, alpha)  # Green color with fading transparency

	# Draw the explosion lines with randomness
	var angle_increment = (2 * PI) / explosion_lines  # Angle between each line
	for i in range(explosion_lines):
		var angle = i * angle_increment + randf_range(-0.2, 0.2)  # Add randomness to the angle
		var length = explosion_length * randf_range(0.8, 1.2)  # Add randomness to the length
		var start = Vector2.ZERO  # Start at the center of the projectile
		var end = Vector2(cos(angle), sin(angle)) * length  # End point of the line
		draw_line(start, end, color, 2.0)  # Draw a green line with fading transparency
