extends Trail
class_name NodeTrail

func _get_position():
	return get_parent().position
