extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var attack_cooldown: Timer = $AttackCooldown

@export var base_life := 10.0
@export var is_directional := false
@export var knockback_recovery = 3.5

@export var dmg = 5.0
@export var move_speed = 30.0

@export var resistance = 0.0
@export var resistance_flat = 0.0

@export var push_force = 100.0

const BASE_KNOCKBACK = 200.0
const MAX_KNOCKBACK = 400.0

@onready var current_life = base_life
@onready var current_push_force = push_force

var target = self
var squish_amount = 0.0
var can_push = true

var is_golden := false

var target_pos := Vector2.ZERO
var knockback = Vector2.ZERO

@onready var hit_area: Area2D = $HitArea
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var is_dying := false
func damage(weapon_damage, weapon_knockback, attack_origin):
	current_life -= weapon_damage
	var pct_lost = weapon_damage/base_life
	squish_amount = 2.0*pct_lost
	var dir = global_position.direction_to(attack_origin)
	var knockback_strength = clamp(BASE_KNOCKBACK * pct_lost * weapon_knockback, 0, MAX_KNOCKBACK)
	knockback = -dir * knockback_strength
	if current_life <= 0:
		if is_golden:
			pass
		
		set_deferred("hit_area.monitorable", false)
		set_deferred("collision_shape_2d.disabled", true)
		is_dying = true


var shadow
func _ready() -> void:
	var rand_float = Lib.rng.randf()
	sprite.material.set_shader_parameter("rand", rand_float)
	if is_directional:
		sprite.flip_h = (rand_float > 0.5)
	
	current_push_force = 50*Lib.rng.randf()
	sprite.material.set_shader_parameter("anim_speed", move_speed*4.0/30.0)
	
	shadow = get_node_or_null("%Shadow")


func _process(delta: float) -> void:
	if !is_equal_approx(squish_amount, 0.0):
		squish_amount = lerp(squish_amount, 0.0, delta * 6.0)
		sprite.material.set_shader_parameter("squish_amount", squish_amount)
	
	if is_dying:
		Lib.lerp_shader_parameter(sprite.material, "alpha", 0.0, delta*25.0)
		if is_instance_valid(shadow):
			Lib.lerp_shader_parameter(shadow.material, "alpha", 0.0, delta*25.0)
		if is_zero_approx(sprite.material.get_shader_parameter("alpha")):
			queue_free()
	
	target_pos = target.global_position
	
	if is_directional and is_instance_valid(target):
		look_at(target_pos)
		rotation += PI/4
		if sprite.flip_h:
			rotation += PI/2
	else:
		sprite.flip_h = target_pos.x < global_position.x
	
	sprite.material.set_shader_parameter("shadow_angle", -rotation)


func _physics_process(_delta: float) -> void:
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	if target != null:
		var direction = global_position.direction_to(target.global_position)
		velocity = direction * move_speed * 1.5
		velocity += knockback
		
		if move_and_slide():
			var collision = get_last_slide_collision()
			var collider = collision.get_collider()
			if collider.is_in_group("Enemy") and can_push:
				var true_push = clamp(current_push_force - collider.current_push_force, 0, 1000)
				if true_push > 0:
					var swap = Vector2(collision.get_normal().y, collision.get_normal().x)
					var cross = (target.global_position-global_position).cross(global_position-collider.global_position)
					if cross > 0:
						swap.x *= -1
					else:
						swap.y *= -1
					collider.velocity = swap * true_push
					collider.move_and_slide()


func _on_hit_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("CursorWeapon"):
		damage(area.current_dmg, area.current_knockback, area.global_position)
