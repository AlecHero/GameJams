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

func _ready() -> void:
	Lib.wave_cleared.connect(wave_cleared)


var slow_heal_amount := 0.0
func wave_cleared():
	slow_heal_amount = ceil(base_life * 0.4)


var init_scale = Vector2(3.0, 3.0)
var t = 1.0
var is_timing := false
var is_low_now := 0
func _process(delta: float) -> void:
	is_low = current_life/base_life < 0.25
	Lib.lerp_shader_parameter(material, "squish_amount", 0.0, delta*10.0)
	
	if slow_heal_amount > 0:
		current_life += 0.1
		slow_heal_amount -= 0.1
		current_life = min(base_life, current_life)
	
	if is_low:
		is_low_now += 1
		
		
		if !is_timing:
			is_timing = true
			get_tree().create_timer(.5).timeout.connect(heart_timeout)
		t = lerp(t, 0.0, delta * 5.0)
		sprite.scale = init_scale + Vector2(2.0, 2.0) * abs(cos((1.0-t)*PI/2))
		Lib.lerp_shader_parameter(material, "saturation", 0.2+0.8 * current_life/(base_life*0.25), delta*5)
	else:
		sprite.scale = init_scale
	
	if is_low_now == 1:
		Music.current_song = Music.SONG_TYPES.LOW_LIFE

func heart_timeout():
	t = 1.0
	is_timing = false

var is_invincible := false
func damage(enemy_damage):
	var mitigated_dmg = max(0, enemy_damage - resistance_flat) * (1.0 - resistance)
	if mitigated_dmg > 0 and !is_invincible:
		is_invincible = true
		invincibility_timer.start()
		
		current_life -= mitigated_dmg
		current_life = max(0.0, current_life)
		if current_life > 0:
			var pct_lost = enemy_damage/base_life
			material.set_shader_parameter("squish_amount", -20.0*pct_lost)
		else:
			die()


func die(): # add die
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
	is_invincible = false
	if hit_area.has_overlapping_bodies():
		if len(hit_area.get_overlapping_bodies()) > 0:
			 # change so it's always the body with the omst dmg
			_on_hit_area_body_entered(hit_area.get_overlapping_bodies()[0])
