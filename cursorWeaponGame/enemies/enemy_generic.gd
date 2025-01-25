extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var rng = RandomNumberGenerator.new()
@onready var attack_cooldown: Timer = $AttackCooldown

@export var base_life := 10.0
@export var is_directional := false
@export var knockback_recovery = 3.5
@export var move_speed = 30.0
@export var dmg = 5.0 :
	get():
		
		attack_cooldown
		return dmg

@export var resistance = 0.0
@export var resistance_flat = 0.0

const MIN_KNOCKBACK = 200.0
const MAX_KNOCKBACK = 400.0

@onready var current_life = base_life
var squish_amount = 0.0
var target
var target_pos := Vector2.ZERO
var knockback = Vector2.ZERO
var main : Node2D

func damage(weapon_damage, weapon_knockback, attack_origin):
	current_life -= weapon_damage
	if current_life > 0:
		var pct_lost = weapon_damage/base_life
		squish_amount = 2.0*pct_lost
		var dir = global_position.direction_to(attack_origin)
		var knockback_strength = clamp(MIN_KNOCKBACK * pct_lost * weapon_knockback, 0, MAX_KNOCKBACK)
		knockback = -dir * knockback_strength
	else:
		queue_free()

func _ready() -> void:
	target = main.get_node("CursorHandler").get_node("%LifeBall")
	sprite.material.set_shader_parameter("rand", rng.randf())
	if is_directional:
		sprite.flip_h = (rng.randf() > 0.5)


func _process(delta: float) -> void:
	if !is_equal_approx(squish_amount, 0.0):
		squish_amount = lerp(squish_amount, 0.0, delta * 6.0)
		sprite.material.set_shader_parameter("squish_amount", squish_amount)
	
	target_pos = target.global_position
	
	if is_directional and is_instance_valid(target):
		look_at(target_pos)
		rotation += PI/4
		if sprite.flip_h:
			rotation += PI/2
	else:
		sprite.flip_h = target_pos.x < global_position.x
	
	sprite.material.set_shader_parameter("shadow_angle", -rotation)


func _physics_process(delta: float) -> void:
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	if target != null:
		var direction = global_position.direction_to(target.global_position)
		velocity = direction * move_speed
		velocity += knockback
		move_and_slide()


func _on_hit_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("CursorWeapon"):
		damage(area.dmg, area.knockback, area.global_position)
