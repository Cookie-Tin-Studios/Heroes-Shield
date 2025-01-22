extends Node

signal coins_changed(new_amount)
signal level_progress_changed(new_amount)
signal max_level_progress_changed(new_amount)

var _coins: int = 0
var _level_progress: int = 0
var _max_level_progress: int = 10000

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
	print("Globals script initialized. Starting with coins =", _coins)

func add_coins(amount: int) -> void:
	coins += amount

func add_progress(amount: int) -> void:
	level_progress += amount
