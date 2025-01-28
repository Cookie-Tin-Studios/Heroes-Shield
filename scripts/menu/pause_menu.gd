extends MarginContainer

const resumeDelay = 300
var timePaused = Time.get_ticks_msec()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _input(_event): 
	if Input.is_action_pressed("Pause"):
		if not get_tree().paused:
			timePaused = Time.get_ticks_msec()
			pause_game()
		elif check_time_delay(Time.get_ticks_msec()):
			resume_game()

func _on_resume_pressed() -> void:
	resume_game()

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file.call_deferred("res://scenes/menu/main_menu.tscn")
	resume_game()

func _on_exit_pressed() -> void:
	get_tree().quit()

func check_time_delay(newPause: int):
	var diff = newPause - timePaused
	return diff > resumeDelay

func pause_game():
	visible = true
	get_tree().paused = true

func resume_game():
	visible = false
	get_tree().paused = false
