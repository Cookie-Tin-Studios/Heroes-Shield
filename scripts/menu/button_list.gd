extends Node

# true if there is already a control that has been focused
var control_focused: Control = null

func _process(delta: float) -> void:
	# don't change focus to first/last button if there already is focus
	if control_focused != null:
		return

	if Input.is_action_just_pressed("ui_down"):
		var b = _get_first_button()
		if b == null:
			return
		b.grab_focus()
		
	elif Input.is_action_just_pressed("ui_up"):
		var b = _get_last_button()
		if b == null:
			return
		b.grab_focus()

func _ready() -> void:
	get_viewport().gui_focus_changed.connect(_on_focus_changed)
	#get_viewport().gui

func _on_focus_changed(control: Control) -> void:
	if control == null:
		return
	control_focused = control
	control.focus_exited.connect(_control_lost_focus)

func _control_lost_focus():
	control_focused.focus_exited.disconnect(_control_lost_focus)
	control_focused = null

# Recursively get all child buttons of the provided node array
static func _get_child_buttons(nodes: Array[Node]) -> Array[Button]:
	var buttons: Array[Button] = []
	
	for child in nodes:
		if child is Button:
			if child.disabled:
				continue
			buttons.append(child)
		else:
			var sub_children = child.get_children()
			buttons.append_array(_get_child_buttons(sub_children))
	
	return buttons

func _get_first_button() -> Button:
	var buttons = _get_child_buttons(get_children())
	for child in buttons:
		if child is Button:
			return child
	return null
	
func _get_last_button() -> Button:
	var buttons = _get_child_buttons(get_children())
	buttons.reverse()
	for child in buttons:
		if child is Button:
			return child
	return null
