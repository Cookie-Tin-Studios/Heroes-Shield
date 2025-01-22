extends MarginContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_back_to_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
	pass # Replace with function body.


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_ez_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
