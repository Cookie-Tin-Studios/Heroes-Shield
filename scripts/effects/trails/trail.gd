extends Line2D
class_name Trail

var queue: Array
@export var max_length: int = 30

func _process(_delta) -> void:
	var pos = _get_position()
	queue.push_front(pos)
	
	if queue.size() > max_length:
		queue.pop_back()

	clear_points()
	for point in queue:
		add_point(point)

func _get_position():
	return get_global_mouse_position()
