extends RigidBody2D

var health: float = mob_health # Initial health is max

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	if $CanvasLayer and $CanvasLayer/TextureProgressBar:
		$CanvasLayer/TextureProgressBar.value = health

	print("Mob has died!")  # Debug message for testing
	if $CanvasLayer:
		$CanvasLayer.queue_free()  # Optional: Remove the health bar
	queue_free()  # Remove the mob from the scene

func _ready() -> void:
	print("Mob is ready!")  # Debug message
	if $CanvasLayer/TextureProgressBar:
		print("Health bar initialized.")
		$CanvasLayer/TextureProgressBar.max_value = mob_health
		$CanvasLayer/TextureProgressBar.value = health
	else:
		print("Error: TextureProgressBar node is missing!")
 
func _process(_delta: float) -> void:
	# Simulate damage when a specific key is pressed (e.g., spacebar)
	if Input.is_action_just_pressed("damage"):
		print("Damage action triggered!")
		take_damage(10)  # Reduce health by 10 when the key is pressed
