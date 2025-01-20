extends Control

@export var full_shield_texture: Texture
@export var empty_shield_texture: Texture

# Updates the health bar display
func update_health_bar(current_health: int, max_health: int):
	print("Updating health bar...")
	print("Current health:", current_health)
	print("Max health:", max_health)
	# Clear the current health bar
	for child in $HBoxContainer.get_children():
		$HBoxContainer.remove_child(child)
		child.queue_free()  # Free the child nodes to avoid memory leaks

	# Add full and empty shields based on current health
	for i in range(max_health):
		var shield_icon = TextureRect.new()
		if i < current_health:
			print("Adding full shield...")
			shield_icon.texture = full_shield_texture
		else:
			print("Adding empty shield...")
			shield_icon.texture = empty_shield_texture

		# Set size and stretch mode for consistency
		shield_icon.custom_minimum_size = Vector2(32, 32)  # Adjust size as needed
		shield_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		$HBoxContainer.add_child(shield_icon)
