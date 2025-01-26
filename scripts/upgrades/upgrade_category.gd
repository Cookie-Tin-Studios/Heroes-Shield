class_name UpgradeCategory

extends Object

var name: String
var upgrades: Array

func _init(name: String, upgrades: Array[Upgrade] = []) -> void:
	self.name = name
	self.upgrades = upgrades
