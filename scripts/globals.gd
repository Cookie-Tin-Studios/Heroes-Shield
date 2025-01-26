extends Node

signal coins_changed(new_amount)
signal level_progress_changed(new_amount)
signal max_level_progress_changed(new_amount)

var _coins: int = 0
var _level_progress: int = 0
var _max_level_progress: int = 10000

# this is set in HUD._ready
var _camera_init: Vector2 = Vector2.ZERO
var camera_offset: Vector2 = Vector2.ZERO

var coins_label_position: Vector2 = Vector2.ZERO
var coins: int:
	get:
		return _coins
	set(value):
		_coins = value
		emit_signal("coins_changed", _coins)

var level_progress: int:
	get:
		return _level_progress
	set(value):
		_level_progress = value
		emit_signal("level_progress_changed", _level_progress)
		
var max_level_progress: int:
	get:
		return _max_level_progress
	set(value):
		_max_level_progress = value
		emit_signal("max_level_progress_changed", _max_level_progress)

func _ready() -> void:
	print("Globals script initialized. Starting with coins = ", _coins)

	
func _process(_delta) -> void:
	var camera = get_viewport().get_camera_2d()
	if is_instance_valid(camera):
		camera_offset = (camera.global_position - _camera_init)
	
func add_coins(amount: int) -> void:
	coins += amount

func add_progress(amount: int) -> void:
	level_progress += amount


var all_upgrades = [
	{
		"category_name": "Movement", 
		"category_upgrades": [
			{
				"upgrade_name": "Speed 1",
				"desc": "You move faster, what did you expect",
				"cost": 1,
			},
			{
				"upgrade_name": "Speed 2",
				"desc": "You move faster, electric boogaloo",
				"cost": 2,
			},
		],	
	},
	{
		"category_name": "Category 2",
		"category_upgrades": [
			{
				"upgrade_name": "Upgrade 1",
				"desc": "Yeah it's an upgrade",
				"cost": 1,
			},
			{
				"upgrade_name": "Upgrade 2",
				"desc": "Yeah it's an upgrade",
				"cost": 2,
			},
		],
	},
	{
		"category_name": "Category 3",
		"category_upgrades": [
			{
				"upgrade_name": "Upgrade 3",
				"desc": "Yeah it's an upgrade",
				"cost": 1,
			},
			{
				"upgrade_name": "Upgrade 4",
				"desc": "Yeah it's an upgrade",
				"cost": 2,
			},
		],
	}
]

var unlocked_upgrades = {
	"Movement": [],
	"Category 2": [],
	"Category 3": []
}
