extends CanvasLayer

@onready var coins_label: Label = $Control/Panel/CoinsLabel
@onready var progress_bar: ProgressBar = $Control/ProgressBar
@onready var progress_icon: Sprite2D = $Control/ProgressBar/ProgressIcon

func _ready() -> void:
	# Connect coin signals (already done in your snippet).
	Globals.connect("coins_changed", Callable(self, "_on_coins_changed"))
	
	# Connect progress signals
	Globals.connect("level_progress_changed", Callable(self, "_on_level_progress_changed"))
	Globals.connect("max_level_progress_changed", Callable(self, "_on_max_level_progress_changed"))

	# Initialize label text
	coins_label.text = "Coins: " + str(Globals.coins)
	Globals.coins_label_position = coins_label.global_position + Vector2(0, 100)

	var camera = get_viewport().get_camera_2d()
	Globals._camera_init = camera.global_position

	# Initialize progress bar with current values
	progress_bar.max_value = Globals.max_level_progress
	progress_bar.value = Globals.level_progress
	
	# Optionally, update the icon position (if you want it to appear in the correct spot at start).
	_update_progress_icon()
	
func _on_coins_changed(new_amount: int) -> void:
	coins_label.text = "Coins: " + str(new_amount)

func _on_level_progress_changed(new_progress: int) -> void:
	progress_bar.value = new_progress
	_update_progress_icon()
	
	# Check if we've reached or exceeded max progress
	if new_progress >= Globals.max_level_progress:
		# Switch to another scene. Modify path as needed.
		get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")


func _on_max_level_progress_changed(new_max: int) -> void:
	progress_bar.max_value = new_max
	# Safely clamp progress in case the new max is smaller, etc.
	progress_bar.value = clamp(progress_bar.value, 0, new_max)
	_update_progress_icon()

func _update_progress_icon() -> void:
	# If you simply want the progress bar's fill to do all the work, you can skip this.
	# But if you want an icon that moves along the bar, you can do something like:
	var ratio = 0.0
	if progress_bar.max_value > 0:
		ratio = float(progress_bar.value) / float(progress_bar.max_value)
	
	# The idea: move the icon from the bar's left edge to its right edge.
	# This is just an example using local position and width. Adjust for your needs.
	var bar_width = progress_bar.get_size().x
	# We'll offset so the icon doesn't go completely off the edges
	var icon_offset = 16.0  # tweak as needed

	var new_x = icon_offset + ratio * (bar_width - 2.0 * icon_offset)
	progress_icon.position.x = new_x
