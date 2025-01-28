extends Control

var all_upgrades = Globals.all_upgrades

@onready var categories_container: HBoxContainer = $MarginContainer/ScrollContainer/CategoriesContainer
@onready var main_menu_button: Button = $MainMenuButton
@onready var coins_label: Label = $Panel/CoinsLabel

func _ready():
	coins_label.text = "Coins: " + str(Globals.coins)
	generate_upgrades_menu()
	main_menu_button.pressed.connect(go_to_main_menu)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_previous_menu"):
		go_to_main_menu()

func clear_container(container: Control) -> void:
	for child in container.get_children():
		child.queue_free()

func generate_upgrades_menu():
	clear_container(categories_container)

	for category_data in all_upgrades:
		var category_name = category_data.name
		var category_upgrades = category_data.upgrades

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
			var upgrade_name = upgrade_data.name
			var desc = upgrade_data.description
			var cost = upgrade_data.cost

			# --- Create a row container for each upgrade ---
			var upgrade_container = HBoxContainer.new()
			upgrade_container.set_alignment(BoxContainer.ALIGNMENT_CENTER)

			# Buy Button
			var buy_button = Button.new()
			buy_button.text = "%s (Cost: %d)" % [upgrade_name, cost]
			buy_button.tooltip_text = desc

			# Check if already unlocked or not enough coins
			var is_unlocked = upgrade_name in Globals.unlocked_upgrades[category_name]
			buy_button.disabled = is_unlocked or Globals.coins < cost

			# Change visual appearance and text if already purchased
			if is_unlocked:
				buy_button.text = "Purchased!"
				buy_button.add_theme_color_override("font_color", Color.LIGHT_GREEN)
				buy_button.add_theme_color_override("bg_color", Color(0.2, 0.5, 0.2))  # Greenish background
			elif buy_button.disabled:
				buy_button.add_theme_color_override("font_color", Color.GRAY)
				buy_button.add_theme_color_override("bg_color", Color(0.3, 0.3, 0.3))  # Dim background

			# Connect button action if not locked
			if not buy_button.disabled:
				buy_button.connect("pressed", Callable(self, "_on_buy_pressed").bind(category_name, upgrade_name, cost))

			upgrade_container.add_child(buy_button)

			# Add this row to the category column
			cat_container.add_child(upgrade_container)

		# Finally, add the entire category column to the main HBox container
		categories_container.add_child(cat_container)

	# Update coins label after generating the menu
	update_coins_label()

func _on_buy_pressed(category_name: String, upgrade_name: String, cost: int) -> void:
	if Globals.coins >= cost:
		# Deduct coins
		Globals.coins -= cost

		# Unlock the upgrade
		if upgrade_name not in Globals.unlocked_upgrades[category_name]:
			Globals.unlocked_upgrades[category_name].append(upgrade_name)
			print("Unlocked upgrade: ", upgrade_name, " in category: ", category_name)

		# Regenerate the upgrades menu to reflect the updated state
		generate_upgrades_menu()
	else:
		print("Not enough coins to buy: ", upgrade_name)

func update_coins_label() -> void:
	coins_label.text = "Coins: " + str(Globals.coins)

func go_to_main_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
