extends VBoxContainer

var upgrade: Upgrade
@onready var description: Label = $description
@onready var upgrade_button: Button = $upgrade

signal purchased(Upgrade)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	upgrade_button.text = "(%s) %s" % [upgrade.Cost, upgrade.Name]
	description.text = upgrade.Description
	

func _on_click() -> void:
	print_debug("purchasing upgrade")
	purchased.emit(upgrade)
	# TODO: Coin Balance check
	# TODO: Coin Balance subtract
