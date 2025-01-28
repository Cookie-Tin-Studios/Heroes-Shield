extends Node

var control_focused: bool = false

func _process(delta: float) -> void:
	if control_focused:
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

func _on_focus_changed(control: Control) -> void:
	control_focused = control != null
	
func _get_child_buttons(nodes: Array[Node]) -> Array[Button]:
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
