extends Node2D

var percent_level_progress: int = 0

# Preload the boss
var boss1_scene = preload("res://scenes/bosses/boss1.tscn")
var boss_spawn_offset = Vector2(1900, -650)
# Variable for referencing idiot node
var idiot_hero: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	percent_level_progress = float(Globals.level_progress) / float(Globals.max_level_progress) * 100
	
	if 0 <= percent_level_progress and percent_level_progress <= 10:
		Globals.bat_max_mobs = 1
		Globals.goblin_max_mobs = 0
	elif 11 <= percent_level_progress and percent_level_progress <= 20:
		Globals.bat_max_mobs = 0
		Globals.goblin_max_mobs = 1
	elif 21 <= percent_level_progress and percent_level_progress <= 65:
		Globals.bat_max_mobs = 1
		Globals.goblin_max_mobs = 1
	elif percent_level_progress == 75:
		Globals.bat_max_mobs = 0
		Globals.goblin_max_mobs = 0
		print("Reached 75 percent completion")
		if get_node_or_null("boss1") == null:
			var boss1_instance = boss1_scene.instantiate()
			boss1_instance.name = "boss1"
			# Get the idiot node so we can put the boss in relative to the idiot
			idiot_hero = get_node("./Idiot_hero")
			# Add an offset to the boss's positon 
			boss1_instance.position = idiot_hero.position + boss_spawn_offset
			add_child(boss1_instance)
	elif percent_level_progress > 75:
		if get_node_or_null("boss1") == null:
			Globals.level_1_boss_defeated = true
