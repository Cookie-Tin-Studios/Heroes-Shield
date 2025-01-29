extends MarginContainer

	
func _process(_delta) -> void:
	if Input.is_action_just_pressed("ui_previous_menu"):
		get_tree().quit()

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_upgrades_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/upgrade_menu.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_controls_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/controls.tscn")
