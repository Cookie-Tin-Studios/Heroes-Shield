extends CanvasLayer

# Selects the Node to apply the text to.
@onready var coins_label: Label = $Control/Panel/CoinsLabel

func _ready() -> void:
	# Connect signal to know when coins change
	Globals.connect("coins_changed", Callable(self, "_on_coins_changed"))
	
	# Set label the first time, since there will be no signal for having no coins.
	coins_label.text = "Coins: " + str(Globals.coins)

func _on_coins_changed(new_amount: int) -> void:
	# Update on coin change signal
	coins_label.text = "Coins: " + str(new_amount)
