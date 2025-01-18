extends MarginContainer

@onready var version = $HBoxContainer/VBoxContainer/Version

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	version.text = "Your Mother v1.1"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
