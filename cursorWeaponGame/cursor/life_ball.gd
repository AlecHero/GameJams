extends RigidBody2D

@export var cursor : Node2D
@export var falloff : Curve

const MAX_DISTANCE = 750
const MAX_SPEED = 300
const SPEED_GAIN = 150

func _physics_process(delta: float) -> void:
	var pin = cursor.pin_position if cursor.is_pinning else get_global_mouse_position()
	var dist_ratio = clamp(global_position.distance_to(pin), 0, MAX_DISTANCE) / MAX_DISTANCE
	
	var dir = global_position.direction_to(pin)
	linear_velocity += dir * SPEED_GAIN * falloff.sample(dist_ratio)
	
	var len = min(10000, linear_velocity.length())
	linear_velocity = linear_velocity.normalized() * len
	
