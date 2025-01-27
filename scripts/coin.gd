extends RigidBody2D

@export var max_speed: float = 100
@export var acceleration: float = 10
@export var despawn_range: float = 500

signal despawn()

func _physics_process(delta: float) -> void:
	var target = to_local(Globals.coins_label_position + Globals.camera_offset)
	
	var angle = position.angle_to_point(target) - linear_velocity.angle()
	
	var towards_target = linear_velocity.rotated(angle) * 3
	#var before = linear_velocity
	#linear_velocity = towards_target
	linear_velocity = linear_velocity.lerp(towards_target, .075)
	#linear_velocity = linear_velocity.move_toward(target, delta * acceleration)
	if position.distance_to(target) <= despawn_range:
		despawn.emit()
		queue_free()
