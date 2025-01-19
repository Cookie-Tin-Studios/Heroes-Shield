extends MarginContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _input(_event): 
	if Input.is_action_pressed("Pause"):
		pause_game()

func _on_resume_pressed() -> void:
	resume_game()

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()


func pause_game():
	visible = true
	get_tree().paused = true

func resume_game():
	visible = false
	get_tree().paused = false
