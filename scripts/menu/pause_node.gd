extends Node

# This node is necessary to pause and unpause the game because all processing is stopped when 
# a node's ProcessMode is `inherit`, but this node is set to `always`

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
