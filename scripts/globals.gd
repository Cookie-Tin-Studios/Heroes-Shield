extends Node

signal coins_changed(new_amount)
signal level_progress_changed(new_amount)
signal max_level_progress_changed(new_amount)

var level_1_boss_defeated: bool = false

# Default spawn rates
var bat_max_mobs: int = 3
var goblin_max_mobs: int = 1

var _coins: int = 0
var _level_progress: int = 0
var _max_level_progress: int = 6000 # 10000 is 1m 4s. I stopwatched it. You're welcome.

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

const movementCategory = "Movement"
const movementSpeed1 = "Speed 1"
const movementSpeed2 = "Speed 2"
const movementSpeed3 = "Dash"

const parryCategory = "Parry Upgrades"
const parryZigZag = "ZigZagParry"
const parryHoming = "HomingParry"

# Define the upgrade categories and their upgrades
var all_upgrades: Array = [
	UpgradeCategory.new(movementCategory, [
		Upgrade.new(movementSpeed1, "You move faster, what did you expect", 10),
		Upgrade.new(movementSpeed2, "You move faster, electric boogaloo", 10),
		Upgrade.new(movementSpeed3, "Adds a dash", 10),
	]),
	UpgradeCategory.new(parryCategory, [
		Upgrade.new(parryZigZag, "Parries projectiles away in a zig zag pattern", 10),
		Upgrade.new(parryHoming, "Parries projectiles into the nearest enemy", 10),
	]),
]

var unlocked_upgrades: Dictionary = {
	movementCategory: [],
	parryCategory: [],
}
