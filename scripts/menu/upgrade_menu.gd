extends MarginContainer

@onready var upgrade_columns: HBoxContainer = $upgrade_columns
@onready var upgrade_category = preload("res://scenes/menu/upgrades/upgrade_category.tscn")

var upgrades = Globals.upgrades

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for category in upgrades:
		var newCategory = upgrade_category.instantiate()
		newCategory.category = category
		upgrade_columns.add_child(newCategory)
	pass # Replace with function body.
