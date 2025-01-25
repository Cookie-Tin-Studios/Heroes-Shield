extends Control

var all_upgrades = Globals.all_upgrades
var unlocked_upgrades = Globals.unlocked_upgrades

@onready var categories_container: VBoxContainer = $MarginContainer/ScrollContainer/CategoriesContainer

func _ready():
	generate_upgrades_menu()

func clear_container(container: Control) -> void:
	for child in container.get_children():
		child.queue_free()

func generate_upgrades_menu():
	clear_container(categories_container)
	
	for category_data in all_upgrades:
		var category_name = category_data.category_name
		var category_upgrades = category_data.category_upgrades
		
		# --- Create a category container ---
		var cat_container = VBoxContainer.new()
		cat_container.name = category_name
		
		# --- Category label ---
		var cat_label = Label.new()
		cat_label.text = category_name
		cat_label.add_theme_color_override("font_color", Color.YELLOW)  # example customization
		cat_container.add_child(cat_label)
		
		# For each upgrade in this category
		for upgrade_data in category_upgrades:
			var upgrade_name = upgrade_data.upgrade_name
			var desc = upgrade_data.desc
			var cost = upgrade_data.cost
			
			# --- Create a container for the upgrade itself ---
			var upgrade_container = HBoxContainer.new()
			
			# --- Upgrade name label ---
			var upgrade_label = Label.new()
			upgrade_label.text = "%s (Cost: %d)".format([upgrade_name, cost])
			upgrade_container.add_child(upgrade_label)
			
			# --- Button for purchasing ---
			var buy_button = Button.new()
			buy_button.text = "Buy"
			buy_button.connect("pressed", Callable(self, "_on_buy_pressed").bind(category_name, upgrade_name))
			upgrade_container.add_child(buy_button)
			
			# --- Optional description label ---
			var desc_label = Label.new()
			desc_label.text = desc
			upgrade_container.add_child(desc_label)
			
			# Add this upgrade_container to the category container
			cat_container.add_child(upgrade_container)
		
		# Finally, add the category container to the main container
		categories_container.add_child(cat_container)


func _on_buy_pressed(category_name: String, upgrade_name: String) -> void:
	# This function is called when the user clicks the "Buy" button for a certain upgrade.
	# Check if it’s already unlocked or if the player can afford it, etc.
	# For example, check currency, etc. Then mark it as unlocked.

	var can_afford = true  # logic to see if the player has enough currency
	if can_afford:
		if upgrade_name not in unlocked_upgrades[category_name]:
			unlocked_upgrades[category_name].append(upgrade_name)
			print("Unlocked upgrade: ", upgrade_name, " in category: ", category_name)
		else:
			print("Already unlocked!")
