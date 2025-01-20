extends Node2D

@onready var shield = get_parent()

@export var section_spacing: float = 65.0
@export var section_texture: Texture2D
@export var empty_section_texture: Texture2D

var sections: Array = []

func _ready():
	call_deferred("create_health_sections")

func create_health_sections():
	# Get max_health from the Shield node
	var max_health = shield.max_health if shield else 0

	# Clear existing sections
	for section in sections:
		section.queue_free()
	sections.clear()

	# Calculate total width of the health bar
	var total_width = (max_health - 1) * section_spacing

	# Start position for centering
	var start_x = -total_width / 2.0

	# Create new sections
	for i in range(max_health):
		var health_section = Sprite2D.new()
		health_section.texture = section_texture  # Use full section texture initially
		health_section.position = Vector2(start_x + i * section_spacing, 0)  # Centered X position
		health_section.scale = Vector2(0.1, 0.3)  # Scale the section if needed
		add_child(health_section)
		sections.append(health_section)

func update_health(current_health: int):
	for i in range(shield.max_health):
		if i < current_health:
			sections[i].texture = section_texture  # Full health texture
		else:
			sections[i].texture = empty_section_texture  # Empty texture
