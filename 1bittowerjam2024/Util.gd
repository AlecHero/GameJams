extends Node

enum ANIMATION_STATES { 
	IDLE, FALL, KNOCKED_R, KNOCKED_L, 
	JUMP_R, JUMP_L, CLIMB_R, CLIMB_L}

const COLOR_TRANSITION_WEIGHT = 0.05

signal scene_changed
signal scene_actual_change
signal next_wave
signal tilemap_changed
signal gold_dropped

func snap(coords):
	return (coords-Vector2(8,8)).snapped(Vector2(16,16))+Vector2(8,8)

func quick_timer(wait_time, timeout_func, is_one_shot = true) -> Timer:
	var timer : Timer = Timer.new()
	timer.autostart = true
	timer.one_shot = is_one_shot
	timer.wait_time = wait_time
	timer.timeout.connect(timeout_func)
	#timer.start()
	return timer

func any_input(actions : Array, use_just := false) -> bool:
	for action in actions:
		if use_just:
			if Input.is_action_just_pressed(action): return true
		else:
			if Input.is_action_pressed(action): return true
	return false
