extends MarginContainer

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_previous_menu"):
		_on_menu_pressed()

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
