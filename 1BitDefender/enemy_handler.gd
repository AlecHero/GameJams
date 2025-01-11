extends Node

@onready var gradient_shader = get_node("../GradientShader")
@onready var spawn_timer: Timer = $SpawnTimer
@onready var wave_timer: Timer = $WaveTimer
@onready var level_handler: Node2D = %LevelHandler
@onready var spawn_node: Node2D = level_handler.get_node("SpawnNode")

var gold_chance := 0.1
var current_beast_type := Enemy.BEAST_TYPES.GOBLIN
var spawn_points : Array[Node]
var current_money := 400 + current_beast_type*100

const ENEMY = preload("res://Prefabs/Enemy/enemy.tscn")
const MAX_TYPE_MINI = 10
const MAX_TYPE_BIG = 4
const MAX_TYPE_MEDIUM = 6

func update_spawn_positions():
	spawn_points = spawn_node.get_children()

func sort_cost(a, b):
	return a[1] < b[1]

func unique(array):
	var unique_list := []
	for i in array:
		if i[1] not in unique_list:
			unique_list.append(i[1])
	return unique_list

func get_costs():
	var beast_cost_indices = []
	for i in range(len(Enemy.BEAST_FLAGS[current_beast_type])):
		var stats_array = get_stats(i, current_beast_type)
		beast_cost_indices.append([i, stats_array["cost"], stats_array["max_life"], stats_array["speed"]])
	beast_cost_indices.sort_custom(sort_cost)
	return beast_cost_indices

func _ready() -> void:
	Util.tilemap_changed.connect(update_spawn_positions)
	Util.scene_changed.connect(change_scene)
	Util.scene_actual_change.connect(update_spawn_positions)
	Util.next_wave.connect(next_wave)

func change_scene(beast_type):
	wave_timer.start()
	spawn_timer.start()
	current_beast_type = beast_type


func spawn_enemy(beast_type : Enemy.BEAST_TYPES, beast_index : int, pos : Vector2):
	var beast = ENEMY.instantiate()
	beast.beast_type = beast_type
	beast.beast_index = beast_index
	beast.beast_flags = Enemy.BEAST_FLAGS[beast_type][beast_index]
	beast.beast_texture = Enemy.BEAST_TEXTURES[beast_type]
	beast.position = pos
	
	var stats = get_stats(beast_index, beast_type)
	beast.max_life = stats["max_life"]
	beast.speed = stats["speed"]
	beast.anim_speed = stats["anim_speed"]
	beast.size = stats["size"]
	beast.power = stats["power"]
	
	beast.is_golden = randf() < gold_chance
	
	get_parent().add_child(beast)


#mini_wave    | lowest -> higher
#medium_wave  | middle -> lowest
#big_wave     | higher -> lowest



func array_n(size, n):
	var filler = []
	filler.resize(size)
	filler.fill(n)
	return filler

func buy_amount(max_buy, money, cost, n_bci):
	if cost is Array: cost = cost.max()
	if n_bci is Array: n_bci = len(n_bci)
	return min(max_buy, floor(money / (cost * n_bci)))

func insert_array_front(arr1, arr2):
	var temp = arr1
	temp.append_array(arr2)
	return temp

var beast_cost_indices
func sort_health(i, j):
	return beast_cost_indices.filter(func(x): return x[0] == i)[0][2] > beast_cost_indices.filter(func(x): return x[0] == j)[0][2]

func get_wave(money : int, wave_type : Enemy.WAVE_TYPE):
	beast_cost_indices = get_costs()
	var unique_costs = unique(beast_cost_indices)
	var unique_costs_rev = unique_costs.duplicate()
	unique_costs_rev.reverse()
	
	var cost_min = beast_cost_indices[0][1]
	var cost_max = beast_cost_indices[-1][1]
	#var n_min = len(beast_cost_indices.filter(func(n): return n[1] == cost_min))
	#var n_max = len(beast_cost_indices.filter(func(n): return n[1] == cost_max))
	#var n_min_prev = 0
	
	var beast_wave = []
	var current_beast_wave = []
	var counter := 0
	
	match wave_type:
		Enemy.WAVE_TYPE.MINI:
			for cost in unique_costs:
				var current_bci = beast_cost_indices.filter(func(n): return n[1] == cost)
				var buy_n = buy_amount(MAX_TYPE_MINI, money, cost, current_bci)
				
				if money < cost_min: break
				#print(money, " ", buy_n, " ", len(current_bci), " ", cost)
				for bci in current_bci:
					current_beast_wave.append_array(array_n(buy_n, bci[0]))
					money -= buy_n*cost
				
				if buy_n != MAX_TYPE_MINI:
					if money >= cost:
						var buy_m = floor(money / cost)
						current_beast_wave.append_array(array_n(buy_m, current_bci[-1][0]))
						money -= buy_m*cost

		Enemy.WAVE_TYPE.BIG:
			for cost in unique_costs_rev:
				var current_bci = beast_cost_indices.filter(func(n): return n[1] == cost)
				var buy_n = buy_amount(MAX_TYPE_BIG, money, cost, current_bci)
				if money < cost_min: break
				for bci in current_bci:
					current_beast_wave.append_array(array_n(buy_n, bci[0]))
					money -= buy_n*cost
				
				#if buy_n != MAX_TYPE_BIG:
					#if money >= cost:
						#var buy_m = floor(money / cost)
						#current_beast_wave.append_array(array_n(buy_m, current_bci[-1][0]))
						#money -= buy_m*cost

		Enemy.WAVE_TYPE.MEDIUM:
			var cost_mid
			if unique_costs.size() % 2 == 0:
				cost_mid = (unique_costs.slice(unique_costs.size()/2-1, unique_costs.size()/2+1))
			else:
				cost_mid = [(unique_costs[ceil(unique_costs.size()/2)])]
			
			var current_bci = beast_cost_indices.filter(func(n): return n[1] in cost_mid)
			var buy_n = buy_amount(MAX_TYPE_MEDIUM, money, cost_mid, current_bci)
			
			for bci in current_bci:
				current_beast_wave.append_array(array_n(buy_n, bci[0]))
				money -= buy_n*bci[1]
			
			var i = 1
			var next_bci = beast_cost_indices.filter(func(n): return n[1] == unique_costs[unique_costs.size()/2+i])
			if money > next_bci.front()[1]:
				var buy_m = buy_amount(MAX_TYPE_MEDIUM, money, next_bci.front()[1], 1)
				current_beast_wave = insert_array_front(current_beast_wave, array_n(buy_m, next_bci.front()[0]))
				money -= buy_m*next_bci.front()[1]
			
			current_beast_wave.sort_custom(sort_health)
			
		Enemy.WAVE_TYPE.RANDOM:
			while money > cost_min:
				var bci = beast_cost_indices.pick_random()
				var buy_n = min(2, floor(money / bci[1]))
				current_beast_wave.append_array(array_n(buy_n, bci[0]))
				money -= buy_n*bci[1]
	
	return current_beast_wave


func has_flag(bitfield, flag): return bool(bitfield & flag)

func get_stats(beast_index, beast_type) -> Dictionary:
	var flags = Enemy.BEAST_FLAGS[beast_type][beast_index]
	var max_life : float = 50.0
	var speed : float
	var anim_speed : float
	var power : float = max_life
	var cost : float = max(20, beast_type * 10)
	var size : float = 1.0
	
	if has_flag(flags, Enemy.FLAGS.ARMORED):
		cost *= 1.4
	if has_flag(flags, Enemy.FLAGS.WEAPON_VARIANT1 & Enemy.FLAGS.WEAPON_VARIANT1):
		cost *= 1.2
		power *= 1.2
	if has_flag(flags, Enemy.FLAGS.FLYING):
		cost *= 2
	if has_flag(flags, Enemy.FLAGS.INVISIBLE):
		cost *= 1.2
	if has_flag(flags, Enemy.FLAGS.STEALTHY):
		cost *= 1.1
	if has_flag(flags, Enemy.FLAGS.CLIMB):
		cost *= 2
	
	if has_flag(flags, Enemy.FLAGS.BRITTLE):
		max_life *= .20
		size *= .75
		cost *= .125
	elif has_flag(flags, Enemy.FLAGS.BUFF):
		max_life *= 1.5
		size *= 1.2 
		cost *= 1.2
	elif has_flag(flags, Enemy.FLAGS.BRUTE):
		max_life *= 2.5
		size *= 1.5 
		cost *= 2.0
	elif has_flag(flags, Enemy.FLAGS.BOSS):
		max_life *= 10.0
		size *= 2
		cost *= 10.0
	power = max_life
	
	if   has_flag(flags, Enemy.FLAGS.SNAIL):
		speed = 0.25 / 5
		power *= 8
		cost *= 0.5
	elif has_flag(flags, Enemy.FLAGS.SLOW):
		speed = 0.8 / 5
		power *= 2
		cost *= 0.9
	elif has_flag(flags, Enemy.FLAGS.SPEEDY):
		speed = 1.5 / 5
		cost *= 1.2
	elif has_flag(flags, Enemy.FLAGS.SONIC):
		speed = 3.0 / 5
		power *= 4
		cost *= 2.0
	else:
		speed = 1.0 / 5
	anim_speed = 10 * (speed * 5)
	
	return {"max_life":max_life, "speed":speed, "anim_speed":anim_speed, "size":size, "power":power, "cost":cost}

var wave_queue = []

func _on_spawn_timer_timeout() -> void:
	if wave_queue.size() > 1:
		spawn_timer.wait_time = 0.75
	else:
		spawn_timer.wait_time = 1.5
	
	if wave_queue.size() > 0:
		if wave_queue.front().size() == 0: wave_queue.pop_front()
		else:
			for spawn_point in spawn_points:
				if wave_queue.front().size() == 0: break
				spawn_enemy(current_beast_type, wave_queue.front().pop_front(), spawn_point.position)

var i := 1
func _on_wave_timer_timeout() -> void:
	var wave_type = Enemy.WAVE_TYPE.values().pick_random()
	wave_queue.append(get_wave(current_money, wave_type))
	#print("money : ", current_money, "\twave : ", i, "\t in_queue : ", wave_queue.size(), "\t wave_type : ", wave_type)
	#print(wave_queue.front())
	i+=1

func next_wave() -> void:
	wave_timer.stop()
	wave_timer.timeout.emit()
	wave_timer.start()
