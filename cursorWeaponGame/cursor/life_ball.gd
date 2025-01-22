extends RigidBody2D

func _physics_process(delta: float) -> void:
	var len = min(5000, linear_velocity.length())
	linear_velocity = linear_velocity.normalized() * len
