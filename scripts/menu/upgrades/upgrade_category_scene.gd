extends Control

var category: UpgradeCategory = UpgradeCategory.new("test", [])
const upgrade_scene: PackedScene = preload("res://scenes/menu/upgrades/upgrade.tscn")

signal purchased(Upgrade)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"Category Name".text = category.Name
	for upgrade in category.Upgrades:
		var newUpgrade = upgrade_scene.instantiate()
		newUpgrade.upgrade = upgrade
		newUpgrade.purchased.connect(_on_upgrade_purchased)
		$HBoxContainer/upgrade_list.add_child(newUpgrade)

func _on_upgrade_purchased(upgrade: Upgrade) -> void:
	purchased.emit(upgrade)
