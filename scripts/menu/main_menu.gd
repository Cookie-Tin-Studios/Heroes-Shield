extends MarginContainer

var playback:AudioStreamPlayback
@onready var start: Button = $HBoxContainer/main_buttons/Start


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start.grab_focus()
	for node in $HBoxContainer/main_buttons.get_children():
		if node is Button:
			# If the added node is a button we connect to its mouse_entered and pressed signals
			# and play a sound
			node.mouse_entered.connect(_play_hover)
			node.focus_entered.connect(_play_hover)
			node.pressed.connect(_play_pressed)
	
func _process(_delta) -> void:
	#TODO: figure out how to do this without exiting straight from upgrade_menu
	#if Input.is_action_pressed("ui_previous_menu"):
		#_on_exit_pressed()
	pass

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_upgrades_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/upgrade_menu.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()

func _enter_tree() -> void:
	# Create an audio player
	var player = AudioStreamPlayer.new()
	add_child(player)

	# Create a polyphonic stream so we can play sounds directly from it
	var stream = AudioStreamPolyphonic.new()
	stream.polyphony = 32
	player.stream = stream
	player.play()
	# Get the polyphonic playback stream to play sounds
	playback = player.get_stream_playback()

	get_tree().node_added.connect(_on_node_added)


func _on_node_added(node:Node) -> void:
	pass


func _play_hover() -> void:
	if not playback.is_stream_playing(0):
		playback.play_stream(preload('res://assets/audio/menu.ogg'), 0, 0, randf_range(0.9, 1.1))


func _play_pressed() -> void:
	if not playback.is_stream_playing(0):
		playback.play_stream(preload('res://assets/audio/menu.ogg'), 0, 0, randf_range(0.9, 1.1))
