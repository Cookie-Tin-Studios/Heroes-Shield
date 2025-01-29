extends Node2D

var percent_level_progress: int = 0

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
	elif 21 <= percent_level_progress and percent_level_progress <= 70:
		Globals.bat_max_mobs = 1
		Globals.goblin_max_mobs = 1
	
