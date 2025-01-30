extends MarginContainer

func _process(_delta) -> void:
	if Input.is_action_just_pressed("ui_previous_menu"):
		_on_main_menu_pressed()

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")


func _on_upgrades_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/upgrade_menu.tscn")
