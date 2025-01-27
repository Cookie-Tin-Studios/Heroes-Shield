extends Node2D

@export var dash_lines: int = 5
@export var spacing: float = 30
@export var color: Color = Color.WHITE
@export var length: int = 100
@export var width: float = 30
var has_effect: bool

const TRAIL = preload("res://scenes/effects/trail.tscn")

func add_effect() -> void:
	var start_offset = -(spacing * dash_lines) / 2
	for i in dash_lines:
		var trail = TRAIL.instantiate()
		trail.width = width
		trail.position = Vector2(0, start_offset + (spacing * i))
		trail.max_length = length
		add_child(trail)
	has_effect = true

func remove_effect() -> void:
	for i in get_children():
		if i is Trail:
			i.queue_free()
	has_effect = false

func _physics_process(delta: float) -> void:
	for i in get_children():
		if i is Trail:
			# yeah this dont work
			#i.rotation = rotation
			pass
