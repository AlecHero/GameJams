extends Node2D

# REGULAR
const SKELLET_1 = preload("res://enemies/skellet1.tscn")
const ORC = preload("res://enemies/orc.tscn")
const CYCLOP = preload("res://enemies/cyclop.tscn")
const HARVESTER = preload("res://enemies/harvester.tscn")
const KNIGHT = preload("res://enemies/knight.tscn")
const PIG_1 = preload("res://enemies/pig1.tscn")
const PIG_2 = preload("res://enemies/pig2.tscn")

# FLAT
const SNAKE = preload("res://enemies/flat_enemy_generic.tscn")

var all_enemies = [SKELLET_1, ORC, CYCLOP, HARVESTER, KNIGHT, PIG_1, PIG_2, SNAKE]

@export var main : Node2D

func get_spawn_pos():
	var vp = get_parent().get_viewport_rect().size
	var padding = 100  # Extra space outside the viewport for spawning
	
	# Randomly decide which side of the screen the enemy will spawn on
	var side = randi() % 4 # 0: top, 1: bottom, 2: left, 3: right
	
	match side:
		0:  # Top
			return Vector2(randf() * vp.x, -padding)
		1:  # Bottom
			return Vector2(randf() * vp.x, vp.y + padding)
		2:  # Left
			return Vector2(-padding, randf() * vp.y)
		3:  # Right
			return Vector2(vp.x + padding, randf() * vp.y)

func spawn_enemy():
	var rand_enemy = all_enemies.pick_random()
	var enemy = rand_enemy.instantiate()
	enemy.position = get_spawn_pos()
	enemy.main = main
	add_child(enemy)


func _on_timer_timeout() -> void:
	spawn_enemy()
