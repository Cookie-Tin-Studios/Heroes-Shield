extends MarginContainer

#@onready var upgrade_columns: HBoxContainer = $upgrade_columns
@onready var upgrade_category = preload("res://scenes/menu/upgrades/upgrade_category.tscn")
const MainMenu = preload("res://scenes/menu/main_menu.tscn")
var upgrades = Globals.upgrades

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for category in upgrades:
		var newCategory = upgrade_category.instantiate()
		newCategory.category = category
		newCategory.purchased.connect(_on_upgrade_purchased)
		$upgrade_columns.add_child(newCategory)

func _process(_delta) -> void:
	if Input.is_action_pressed("ui_previous_menu"):
		print_debug("going back to main menu")
		get_tree().change_scene_to_packed(MainMenu)

func _on_upgrade_purchased(upgrade: Upgrade) -> void:
	Globals.active_upgrades.append(upgrade)
