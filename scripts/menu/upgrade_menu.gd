extends Control

var all_upgrades = Globals.all_upgrades
var unlocked_upgrades = Globals.unlocked_upgrades

# IMPORTANT: Change the type of `CategoriesContainer` to HBoxContainer in the Editor
@onready var categories_container: HBoxContainer = $MarginContainer/ScrollContainer/CategoriesContainer
@onready var main_menu_button: Button = $MainMenuButton

func _ready():
	generate_upgrades_menu()
	main_menu_button.pressed.connect(go_to_main_menu)

func clear_container(container: Control) -> void:
	for child in container.get_children():
		child.queue_free()

func generate_upgrades_menu():
	clear_container(categories_container)
	
	for category_data in all_upgrades:
		var category_name = category_data.category_name
		var category_upgrades = category_data.category_upgrades
		
		# --- Create a VERTICAL container for each category (a "column") ---
		var cat_container = VBoxContainer.new()
		cat_container.name = category_name
		cat_container.set_alignment(BoxContainer.ALIGNMENT_CENTER)
		
		# Optional: Expand so each column tries to use space more evenly
		cat_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
		cat_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		# --- Category label at the top of the column ---
		var cat_label = Label.new()
		cat_label.text = category_name
		cat_label.add_theme_color_override("font_color", Color.YELLOW)
		cat_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

		cat_container.add_child(cat_label)
		
		# For each upgrade in this category, add a row (HBox)
		for upgrade_data in category_upgrades:
			var upgrade_name = upgrade_data.upgrade_name
			var desc = upgrade_data.desc
			var cost = upgrade_data.cost
			
			# --- Create a row container for each upgrade ---
			var upgrade_container = HBoxContainer.new()
			upgrade_container.set_alignment(BoxContainer.ALIGNMENT_CENTER)
			
			# 2) Buy Button
			var buy_button = Button.new()
			buy_button.text =  "%s (Cost: %d)" % [upgrade_name, cost]
			buy_button.connect("pressed", Callable(self, "_on_buy_pressed").bind(category_name, upgrade_name))
			buy_button.tooltip_text = desc

			upgrade_container.add_child(buy_button)
			
			
			
			# Add this row to the category column
			cat_container.add_child(upgrade_container)
		
		# Finally, add the entire category column to the main HBox container
		categories_container.add_child(cat_container)

func _on_buy_pressed(category_name: String, upgrade_name: String) -> void:
	var can_afford = true  # your logic here
	if can_afford:
		if upgrade_name not in unlocked_upgrades[category_name]:
			unlocked_upgrades[category_name].append(upgrade_name)
			print("Unlocked upgrade: ", upgrade_name, " in category: ", category_name)
		else:
			print("Already unlocked!")

func go_to_main_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
