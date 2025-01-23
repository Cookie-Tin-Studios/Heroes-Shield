extends VBoxContainer

var upgrade: Upgrade
@onready var description: Label = $description
@onready var upgrade_button: Button = $upgrade

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	upgrade_button.text = "(%s) %s" % [upgrade.Cost, upgrade.Name]
	description.text = upgrade.Description
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
