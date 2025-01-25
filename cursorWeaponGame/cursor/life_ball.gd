extends RigidBody2D

@export var cursor : Node2D
@export var falloff : Curve
@export var base_life := 100.0
@export var resistance = 0.0
@export var resistance_flat = 0.0

const MAX_DISTANCE = 750
const MAX_SPEED = 300
const SPEED_GAIN = 150

@onready var current_life := base_life


func _process(delta: float) -> void:
	
	pass


func damage(enemy_damage):
	current_life -= max(0, enemy_damage - resistance_flat) * (1.0 - resistance)
	
	if current_life > 0:
		var pct_lost = enemy_damage/base_life
		
	else:
		die()


func die():
	print("U FUCKING DIED BRO")


func _physics_process(delta: float) -> void:
	var pin = cursor.pin_position if cursor.is_pinning else get_global_mouse_position()
	var dist_ratio = clamp(global_position.distance_to(pin), 0, MAX_DISTANCE) / MAX_DISTANCE
	
	var dir = global_position.direction_to(pin)
	linear_velocity += dir * SPEED_GAIN * falloff.sample(dist_ratio)
	
	var len = min(10000, linear_velocity.length())
	linear_velocity = linear_velocity.normalized() * len


func _on_hit_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		print(body)
		damage(body.dmg)
