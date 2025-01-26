extends "res://scripts/mobs/mob_base.gd"

@onready var global_tick = get_node("/root/Tick")

# Determines how far above (or below) the collision shape the health bar should appear.
@export var health_bar_offset: Vector2 = Vector2(0, -20)
@export var health_bar_follow_collision: bool = true

func _ready() -> void:
	super._ready()
	# Connect the global tick signal so the bat shoots projectiles periodically.
	global_tick.timeout.connect(_on_tick)

func _on_tick() -> void:
	# Trigger a projectile shot every time the global tick fires.
	if health != 0:
		shoot_projectile()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	# If enabled, place the health bar above the collision shape by the specified offset.
	if health_bar_follow_collision and $CollisionShape2D and $Node2D:
		var collision_pos = $CollisionShape2D.position
		$Node2D.position = collision_pos + health_bar_offset
