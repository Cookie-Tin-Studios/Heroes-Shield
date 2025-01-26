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
	
	# Update the collision to match the line
	var collision_shape: CollisionShape2D = $CollisionShape2D
	var segment_shape: SegmentShape2D = SegmentShape2D.new()
	segment_shape.a = start_pos
	segment_shape.b = end_pos
	collision_shape.shape = segment_shape
