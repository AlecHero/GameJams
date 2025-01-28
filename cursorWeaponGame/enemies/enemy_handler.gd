extends Node2D

const SNAKE = preload("res://enemies/snake.tscn")
const SKELETON_1 = preload("res://enemies/skeleton1.tscn")
const SKELETON_2 = preload("res://enemies/skeleton2.tscn")
const ORC_1 = preload("res://enemies/orc1.tscn")
const ORC_2 = preload("res://enemies/orc2.tscn")
const CYCLOP_1 = preload("res://enemies/cyclop1.tscn")
const CYCLOP_2 = preload("res://enemies/cyclop2.tscn")
const HARVESTER = preload("res://enemies/harvester.tscn")
const PIG_1 = preload("res://enemies/pig1.tscn")
const PIG_2 = preload("res://enemies/pig2.tscn")
const KNIGHT_1 = preload("res://enemies/knight1.tscn")
const KNIGHT_2 = preload("res://enemies/knight2.tscn")
const RAPTOR = preload("res://enemies/raptor.tscn")
const FISH = preload("res://enemies/fish.tscn")

enum ENEMY_TYPE { SNAKE, SKELETON, ORC, CYCLOP, HARVESTER, PIG, KNIGHT, RAPTOR }
const enemy_dict = {
	ENEMY_TYPE.SNAKE:     { SNAKE: 1.0 },
	ENEMY_TYPE.SKELETON:  { SKELETON_1: 3.0, SKELETON_2: 1.0 },
	ENEMY_TYPE.ORC:       { ORC_1: 1.0, ORC_2: 1.0 },
	ENEMY_TYPE.CYCLOP:    { CYCLOP_1: 1.0, CYCLOP_2: 1.0 },
	ENEMY_TYPE.HARVESTER: { HARVESTER: 1.5, FISH: 1.0 },
	ENEMY_TYPE.PIG:       { PIG_1: 1.0, PIG_2: 1.0 },
	ENEMY_TYPE.KNIGHT:    { KNIGHT_1: 1.0, KNIGHT_2: 1.0 },
	ENEMY_TYPE.RAPTOR:    { RAPTOR: 1.0 }
};

const MAX_ENEMIES = 300

@export var main : Node2D
@export var cursor_handler: Node2D
@onready var life_ball = cursor_handler.get_node("%LifeBall")
@onready var vp = get_parent().get_viewport_rect().size


func get_square_pos():
	var padding = 20
	var side = Lib.rng.randi() % 4
	match side:
		0: return Vector2(Lib.rng.randf() * vp.x, -padding)
		1: return Vector2(Lib.rng.randf() * vp.x, vp.y + padding)
		2: return Vector2(-padding, Lib.rng.randf() * vp.y)
		3: return Vector2(vp.x + padding, Lib.rng.randf() * vp.y)


func spawn_enemy(enemy_type, pos):
	var enemy = Lib.pick_weighted(enemy_dict[enemy_type]).instantiate()
	enemy.position = pos
	enemy.target = life_ball
	add_child(enemy)


func spawn_swarm(enemy_type, spawn_count : float, time=5):
	var circ = Lib.circle_encompassing_viewport(vp)
	var time_per_spawn = time/spawn_count
	for i in spawn_count:
		var spawn_position = Lib.rand_circle_position(circ)
		spawn_enemy(enemy_type, spawn_position)
		await get_tree().create_timer(time_per_spawn).timeout


func spawn_cluster(enemy_type, spawn_count):
	var circ = Lib.circle_encompassing_viewport(vp)
	circ["radius"] *= 1.25
	var spawn_position = Lib.rand_circle_position(circ)
	var time_per_spawn = 0.5 / spawn_count
	var n_side = ceilf(sqrt(spawn_count))
	var px_amount = 24
	var count = 0
	for i in n_side:
		for j in n_side:
			if count == spawn_count: return
			count += 1
			# hexagonal pattern
			var vec_add = (Vector2(i * sqrt(3.0), j + fmod(i, 2.0)/2) * px_amount)
			spawn_enemy(enemy_type, spawn_position + vec_add)
			await get_tree().create_timer(time_per_spawn).timeout


func spawn_circle(enemy_type, spawn_count):
	var circ = Lib.circle_encompassing_viewport(vp)
	var spawn_positions = Lib.get_points_on_circle(circ["center"], circ["radius"], spawn_count)
	for pos in spawn_positions:
		spawn_enemy(enemy_type, pos)

enum WAVE_TYPE { CIRCLE, CLUSTER, SWARM }
var wave_dict = {
	WAVE_TYPE.CIRCLE: spawn_circle,
	WAVE_TYPE.CLUSTER: spawn_cluster,
	WAVE_TYPE.SWARM: spawn_swarm,
}

var wave_list = [
	{"time":00_05, "enemy_type":ENEMY_TYPE.SNAKE, "wave_type":WAVE_TYPE.CIRCLE, "spawn_count":32},
	{"time":00_10, "enemy_type":ENEMY_TYPE.RAPTOR, "wave_type":WAVE_TYPE.CLUSTER, "spawn_count":32},
]

var current_spawn_count := 32.0
func _ready() -> void:
	_on_timer_timeout()


var current_wave_index := 0
var wave_time_passed := 0.0
func _process(delta: float) -> void:
	if current_wave_index <= (len(wave_list)-1):
		var Wave = wave_list[current_wave_index]
		if Wave["time"] < Time.get_ticks_msec() / 1000.0:
			current_wave_index += 1
			wave_dict[Wave["wave_type"]].call(Wave["enemy_type"], Wave["spawn_count"])


func _on_timer_timeout() -> void:
	pass
	#if MAX_ENEMIES > (get_child_count() + current_spawn_count):
		#spawn_cluster(ENEMY_TYPE.SKELETON, current_spawn_count)
