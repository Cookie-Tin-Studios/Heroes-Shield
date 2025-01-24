extends Upgrade

class_name MovementUpgrade

var buff_percent: float

func _init(name: String, desc: String, cost: int, buff: float):
	super(name, desc, cost)
	buff_percent = buff
