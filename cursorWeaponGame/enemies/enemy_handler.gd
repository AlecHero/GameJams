extends Node

const ENEMY_GENERIC = preload("res://enemies/enemy_generic.tscn")

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
	var enemy = ENEMY_GENERIC.instantiate()
	enemy.position = get_spawn_pos()
	#enemy.base_life 
	get_parent().add_child(enemy)


func _on_timer_timeout() -> void:
	spawn_enemy()
