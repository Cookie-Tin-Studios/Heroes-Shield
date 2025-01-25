class_name Upgrade
extends VBoxContainer

@onready var description: Label = $description
@onready var upgrade_button: Button = $upgrade
const UPGRADE = preload("res://scenes/menu/upgrades/upgrade.tscn")

# === Data Structure ===
signal purchased(Upgrade)
var Name: String
var Description: String
var Cost: int

static func new_upgrade_scene(name: String, desc: String, cost: int) -> Upgrade:
	var new_upgrade = UPGRADE.instantiate()
	new_upgrade.Name = name
	new_upgrade.Description = desc
	new_upgrade.Cost = cost
	return new_upgrade

# === Scene Methods ===
func _ready() -> void:
	upgrade_button.text = "(%s) %s" % [Cost, Name]
	description.text = Description

func _on_click() -> void:
	print_debug("purchasing upgrade")
	purchased.emit(self)
	# TODO: Coin Balance check
	# TODO: Coin Balance subtract
