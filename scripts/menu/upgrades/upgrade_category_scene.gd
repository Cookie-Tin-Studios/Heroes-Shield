extends Control

var category: UpgradeCategory
@onready var category_name: Label = $"Category Name"
@onready var upgrade_list: VBoxContainer = $HBoxContainer/upgrade_list
const upgrade_scene = preload("res://scenes/menu/upgrades/upgrade.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	category_name.text = category.Name
	for upgrade in category.Upgrades:
		var newUpgrade = upgrade_scene.instantiate()
		newUpgrade.upgrade = upgrade
		upgrade_list.add_child(newUpgrade)
		pass
