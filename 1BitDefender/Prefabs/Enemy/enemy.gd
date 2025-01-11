extends Area2D

@export var beast_type : Enemy.BEAST_TYPES
@export var beast_texture : Texture2D

@onready var enemy_handler: Node = get_node("../EnemyHandler")
@onready var level_handler: Node2D = $"../LevelHandler"
@onready var sprite_shader: ShaderMaterial = $Sprite2D.material
@onready var healthbar_shader: ShaderMaterial = $HealthBar.material
@onready var tower: StaticBody2D = $"../Tower"
@onready var sprite: Sprite2D = $Sprite2D
@onready var health_bar: ProgressBar = $HealthBar
@onready var particle_golden: GPUParticles2D = $ParticleGolden

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var armor: Node2D = $Armor

const BLOCK_CHANCE = 0.33

var current_path: Array[Vector2i]
var beast_flags
var beast_index : int
var max_life : float = 50.0
var current_life : float
var speed : float
var anim_speed : float
var size : float
var power : float

var is_golden : bool
var is_dying := false
var gates_active : Array[int]
var invisibility_alpha
var slow_factor := 1.0

enum DEATH_TYPES {SLICE, VANISH, EXPLODE}
var death_type := DEATH_TYPES.SLICE

func has_flag(flag : int) -> bool: return bool(beast_flags & flag)

func any_flag(flags : Array[int]) -> bool:
	for flag in flags:
		if has_flag(flag): return true
	return false

func all_flags(flags : Array[int]) -> bool:
	for flag in flags:
		if not has_flag(flag): return false
	return true

func update_path() -> void:
	if has_flag(Enemy.FLAGS.FLYING):
		current_path = AStarUtil.get_type_path(level_handler, global_position, tower.global_position, AStarUtil.ASTAR_TYPES.FLYING, gates_active)
	if has_flag(Enemy.FLAGS.CLIMB):
		current_path = AStarUtil.get_type_path(level_handler, global_position, tower.global_position, AStarUtil.ASTAR_TYPES.CLIMB, gates_active)
	else:
		current_path = AStarUtil.get_type_path(level_handler, global_position, tower.global_position, AStarUtil.ASTAR_TYPES.REGULAR, gates_active)


func _ready() -> void:
	Util.scene_changed.connect(die)
	
	sprite.frame = beast_index
	sprite.texture = beast_texture
	sprite.scale *= size
	current_life = max_life
	sprite_shader.set_shader_parameter("alpha", 0)
	sprite_shader.set_shader_parameter("columns", sprite.hframes)
	sprite_shader.set_shader_parameter("rows", sprite.vframes)
	sprite_shader.set_shader_parameter("frame", beast_index)
	sprite_shader.set_shader_parameter("angle", randf_range(0, PI))
	particle_golden.emitting = is_golden
	
	healthbar_shader.set_shader_parameter("alpha", 0)
	if has_flag(Enemy.FLAGS.BRITTLE):
		healthbar_shader.set_shader_parameter("grille_amount", 1)
	elif has_flag(Enemy.FLAGS.BUFF):
		healthbar_shader.set_shader_parameter("grille_amount", 8)
	elif has_flag(Enemy.FLAGS.BRUTE):
		healthbar_shader.set_shader_parameter("grille_amount", 12)
	elif has_flag(Enemy.FLAGS.BOSS):
		healthbar_shader.set_shader_parameter("grille_amount", 20)
	else:
		healthbar_shader.set_shader_parameter("grille_amount", 5)
	
	
	if has_flag(Enemy.FLAGS.INVISIBLE):  invisibility_alpha = 0.2
	elif has_flag(Enemy.FLAGS.STEALTHY): invisibility_alpha = 0.4
	else:                                             invisibility_alpha = 1.0
	
	#if has_flag(beast_flags, Enemy.FLAGS.ARMORED): pass
	if beast_type == Enemy.BEAST_TYPES.SPIRIT:
		if any_flag([Enemy.FLAGS.INVISIBLE, Enemy.FLAGS.BOSS]):
			sprite_shader.set_shader_parameter("is_wavy", true)
		if has_flag(Enemy.FLAGS.FLYING):
			sprite_shader.set_shader_parameter("is_flying", true)
	elif has_flag(Enemy.FLAGS.CLIMB):
		sprite_shader.set_shader_parameter("is_climby", true)
	
	gates_active = [round(randf()),round(randf()),round(randf()),round(randf())]
	update_path()
	Util.tilemap_changed.connect(update_path)
	sprite_shader.set_shader_parameter("anim_speed", anim_speed)


var t = 0.0
var dying_t = 0.0
func _process(delta: float) -> void:
	if is_dying:
		sprite_shader.set_shader_parameter("t", dying_t)
		dying_t = lerp(dying_t, 1.0, 0.05)
		if dying_t > 0.9:
			queue_free()
	
	if !is_equal_approx(t, invisibility_alpha):
		healthbar_shader.set_shader_parameter("alpha", t)
		sprite_shader.set_shader_parameter("alpha", t)
		
		if has_flag(Enemy.FLAGS.INVISIBLE):  t = lerp(t, invisibility_alpha, 2*delta)
		elif has_flag(Enemy.FLAGS.STEALTHY): t = lerp(t, invisibility_alpha, 0.5*delta)
		else:                                t = lerp(t, invisibility_alpha, delta)
	
	var lerped_squish = lerp(sprite_shader.get_shader_parameter("squish_amount"), 0.0, 0.05)
	sprite_shader.set_shader_parameter("squish_amount", lerped_squish)
	
	health_bar.material.set_shader_parameter("progress", current_life/max_life)
	if current_life <= 0:
		death_type = DEATH_TYPES.SLICE
		die()


func _physics_process(_delta: float) -> void:
	if current_path.is_empty(): return
	var target_position = level_handler.current_layer.map_to_local(current_path.front())
	global_position = global_position.move_toward(target_position, speed*slow_factor*1.0)
	if global_position == target_position: current_path.pop_front()


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Tower":
		body.hit(power)
		death_type = DEATH_TYPES.VANISH
		die()

func die():
	if not is_dying:
		is_dying = true
		health_bar.hide()
		sprite_shader.set_shader_parameter("is_dying", true)
		sprite_shader.set_shader_parameter("death_type", death_type)
		set_deferred("collision_shape_2d.disabled", true)
		set_deferred("speed", 0.0)
		if is_golden:
			AudioController.play("coin_drop")
			Util.gold_dropped.emit(1)
		else:
			match beast_type:
				Enemy.BEAST_TYPES.GOBLIN:
					AudioController.play("monster_death")
				Enemy.BEAST_TYPES.SKELETON:
					AudioController.play("skeleton_death")
				Enemy.BEAST_TYPES.CYCLOPS:
					AudioController.play("monster_death")
				Enemy.BEAST_TYPES.SPIRIT:
					AudioController.play("spirit_death")


func hit(damage, damage_type) -> void:
	if any_flag([Enemy.FLAGS.FLYING, Enemy.FLAGS.CLIMB]) and (damage_type == "Vine" or damage_type == "Spikes"): pass
	elif has_flag(Enemy.FLAGS.ARMORED) and not (damage_type == "Vine" or damage_type == "Spikes") and (randf() < BLOCK_CHANCE):
		armor.is_activated = true
		AudioController.play("hit_metal")
	else:
		current_life -= damage
		AudioController.play("hit_enemy")
		# Impact squish:
		var squish_amount = clamp((randf() * 1.25 - 0.75) * (1.0 + 12.0*damage/max_life), -4.0, 4.0)
		sprite_shader.set_shader_parameter("squish_amount", squish_amount)
		# Make slightly visible:
		if has_flag(Enemy.FLAGS.INVISIBLE): t += 0.05
		if has_flag(Enemy.FLAGS.STEALTHY):  t += 1.0
