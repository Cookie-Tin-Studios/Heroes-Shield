extends Node2D
@export var size: float = 10

func _draw():
	draw_circle(position, size, Color.WHITE)
