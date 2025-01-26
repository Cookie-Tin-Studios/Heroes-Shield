extends StaticBody2D

var _width: float = 10
@export var width: float:
	get:
		return _width
	set(value):
		_width = value
		update_points()

var _start_pos: Vector2 = Vector2.ZERO
var start_pos: Vector2:
	get:
		return _start_pos
	set(position):
		_start_pos = Vector2(position)
		update_points()

var _end_pos: Vector2 = Vector2.ZERO
var end_pos: Vector2:
	get:
		return _end_pos
	set(position):
		_end_pos = Vector2(position)
		update_points()


func update_points() -> void:
	var line_2d: Line2D = $Line2D
	line_2d.clear_points()
	line_2d.add_point(start_pos)
	line_2d.add_point(end_pos)
	line_2d.width = width
	update_collision()

func update_collision() -> void:
	var collision_shape_2d: CollisionShape2D = $CollisionShape2D
	var line_2d: Line2D = $Line2D
	var new_rect = RectangleShape2D.new()
	new_rect.size = Vector2(width, _start_pos.distance_to(_end_pos))
	var r = new_rect.get_rect()
	collision_shape_2d.shape = new_rect
	collision_shape_2d.position = Vector2(_start_pos.x + _end_pos.x, _start_pos.y + _end_pos.y) / 2
	collision_shape_2d.rotate(_start_pos.angle_to_point(_end_pos))
