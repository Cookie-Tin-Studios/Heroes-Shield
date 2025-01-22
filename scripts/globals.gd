extends Node

# Notify on coin change.
signal coins_changed(new_amount)

# Global coin variable w setter and getter.
var coins: int:
	get():
		return coins
	set(value):
		coins = value
		emit_signal("coins_changed", coins)

func _ready():
	print("Globals script initialized. Starting with coins =", coins)

func add_coins(amount: int) -> void:
	coins += amount
