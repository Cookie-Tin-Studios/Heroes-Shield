extends StaticBody2D

#@export var start_pos: Vector2
#@export var end_pos: Vector2
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
	line_2d.width = 1000.0  # Adjust thickness visually if you like


#func _ready() -> void:
	# 1) Draw the line visually with Line2D
	#var line_2d: Line2D = $Line2D
	#line_2d.add_point(start_pos)
	#line_2d.add_point(end_pos)
	#line_2d.width = 1000.0  # Adjust thickness visually if you like

	# 2) Create the collision shape (SegmentShape2D)
	#var collision_shape_2d: CollisionShape2D = $CollisionShape2D
	#var segment: SegmentShape2D = SegmentShape2D.new()
	#segment.a = start_pos
	#segment.b = end_pos

	#collision_shape_2d.shape = segment
