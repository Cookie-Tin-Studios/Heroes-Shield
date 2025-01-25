class_name UpgradeCategory
extends Control

signal purchased(Upgrade)
var Name: String
var Upgrades: Array[Upgrade]
const UPGRADE_CATEGORY = preload("res://scenes/menu/upgrades/upgrade_category.tscn")

static func new_upgrade_category_scene(name: String, upgrades: Array[Upgrade]) -> UpgradeCategory:
	var new_category = UPGRADE_CATEGORY.instantiate()
	new_category.Name = name
	new_category.Upgrades = upgrades
	return new_category


func _ready() -> void:
	$"Category Name".text = Name
	for upgrade in Upgrades:
		$HBoxContainer/upgrade_list.add_child(upgrade)
		upgrade.purchased.connect(_on_upgrade_purchased)

func _on_upgrade_purchased(upgrade: Upgrade) -> void:
	purchased.emit(upgrade)
