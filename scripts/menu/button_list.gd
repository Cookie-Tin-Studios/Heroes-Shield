extends Node

# true if there is already a control that has been focused
var control_focused: Control = null
var playback: AudioStreamPlayback

func _process(delta: float) -> void:
	# don't change focus to first/last button if there already is focus
	if control_focused != null:
		return

	if Input.is_action_just_pressed("ui_down"):
		var b = _get_first_button(_get_child_buttons(get_children()))
		if b == null:
			return
		b.grab_focus()

	elif Input.is_action_just_pressed("ui_up"):
		var b = _get_last_button(_get_child_buttons(get_children()))
		if b == null:
			return
		b.grab_focus()

func _ready() -> void:
	get_viewport().gui_focus_changed.connect(_on_focus_changed)
	child_entered_tree.connect(_child_added)
	for node in _get_child_buttons(get_children()):
		if node is Button:
			# If the added node is a button we connect to its mouse_entered and pressed signals
			# and play a sound
			node.mouse_entered.connect(_play_hover)
			node.focus_entered.connect(_play_hover)
			node.pressed.connect(_play_pressed)

# needed for things like the upgrade screen
func _child_added(node: Node) -> void:
	if node is Button:
		_connect_button_to_sound.call_deferred(node)
		return
	# if a container holding buttons enters, we don't want to miss those
	for button in _get_child_buttons(get_children()):
		_connect_button_to_sound.call_deferred(button)

# play sound effects on a given button (only if it's not already doing so)
func _connect_button_to_sound(button: Button) -> void:
	if button.focus_entered.is_connected(_play_hover):
		return
	button.mouse_entered.connect(_play_hover)
	button.focus_entered.connect(_play_hover)
	button.pressed.connect(_play_pressed)

# === Focus
func _on_focus_changed(control: Control) -> void:
	if control == null:
		return
	control_focused = control
	control.focus_exited.connect(_control_lost_focus)

# remove reference to control if focus is lost (_on_focus_changed does not track loss of focus)
func _control_lost_focus():
	control_focused.focus_exited.disconnect(_control_lost_focus)
	control_focused = null

# === Button sounds
func _play_hover() -> void:
	if not playback.is_stream_playing(0):
		playback.play_stream(preload('res://assets/audio/menu.ogg'), 0, 0, randf_range(0.9, 1.1))

func _play_pressed() -> void:
	if not playback.is_stream_playing(0):
		playback.play_stream(preload('res://assets/audio/menu.ogg'), 0, 0, randf_range(0.9, 1.1))

# register the audio player when this node enters the tree
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

# === Button children helpers
# Recursively get all child buttons of the provided node array
static func _get_child_buttons(nodes: Array[Node]) -> Array[Button]:
	var buttons: Array[Button] = []
	
	for child in nodes:
		if child is Button:
			buttons.append(child)
		else:
			var sub_children = child.get_children()
			buttons.append_array(_get_child_buttons(sub_children))
	
	return buttons

static func _get_first_button(buttons: Array[Button]) -> Button:
	for child in buttons:
		if child is not Button:
			return null
		if child.disabled:
			continue
		return child
	return null
	
static func _get_last_button(buttons: Array[Button]) -> Button:
	buttons.reverse()
	return _get_first_button(buttons)
