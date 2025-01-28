extends RigidBody2D

@onready var invincibility_timer: Timer = $InvincibilityTimer
@onready var hit_area: Area2D = $HitArea
@onready var sprite: Sprite2D = $Sprite2D

@export var cursor : Node2D
@export var falloff : Curve
@export var base_life := 100.0
@export var resistance = 0.0
@export var resistance_flat = 0.0

const MAX_DISTANCE = 750
const MAX_SPEED = 300
const SPEED_GAIN = 150

@onready var current_life := base_life

var is_low := false

var init_scale = Vector2(3.0, 3.0)
var t = 1.0
var is_timing := false
func _process(delta: float) -> void:
	is_low = current_life/base_life < 0.25
	
	if is_low:
		if Music.is_playing(Music.SONG_LOW):
			Music.play(Music.SONG_LOW)
		if !is_timing:
			is_timing = true
			get_tree().create_timer(.5).timeout.connect(heart_timeout)
		t = lerp(t, 0.0, delta * 5.0)
		sprite.scale = init_scale + Vector2(2.0, 2.0) * abs(cos((1.0-t)*PI/2))
		Lib.lerp_shader_parameter(material, "saturation", 0.2+0.8 * current_life/(base_life*0.25), delta*5)
	else:
		sprite.scale = init_scale

func heart_timeout():
	t = 1.0
	is_timing = false

func damage(enemy_damage):
	var mitigated_dmg = max(0, enemy_damage - resistance_flat) * (1.0 - resistance)
	if mitigated_dmg > 0:
		invincibility_timer.start()
		hit_area.set_deferred("monitoring", false)
		
		current_life -= mitigated_dmg
		current_life = max(0.0, current_life)
		if current_life > 0:
			#var pct_lost = enemy_damage/base_life
			pass
		else:
			die()


func die():
	pass

func _physics_process(_delta: float) -> void:
	var pin = cursor.pin_position if cursor.is_pinning else get_global_mouse_position()
	var dist_ratio = clamp(global_position.distance_to(pin), 0, MAX_DISTANCE) / MAX_DISTANCE
	
	var dir = global_position.direction_to(pin)
	linear_velocity += dir * SPEED_GAIN * falloff.sample(dist_ratio)
	
	var len1 = min(10000, linear_velocity.length())
	linear_velocity = linear_velocity.normalized() * len1


func _on_hit_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		damage(body.dmg)


func _on_invincibility_timer_timeout() -> void:
	hit_area.set_deferred("monitoring", true)
