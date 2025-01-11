extends Node

const GRAVITY = 2000

enum ANIMATION_STATES { 
	IDLE, FALL, KNOCKED_R, KNOCKED_L, 
	JUMP_R, JUMP_L, CLIMB_R, CLIMB_L, 
	FLYING_R, FLYING_L, FLYING_IDLE, DEAD,
	STUCK_R, STUCK_L, SWIM_R, SWIM_L }
const ANIM_SPEED = 40.0
const BIG_ANIM_SPEED = ANIM_SPEED/2

const SPEED = 330.0
const SMALL_SCALE = Vector2(1.0,1.0)
const JUMP_VELOCITY = -640.0
const WATER_JUMP_VELOCITY = JUMP_VELOCITY*10
const JUMP_SQUISH = -1.0
const JUMP_IMPACT = 1.0
const CLIMB_SPEED = 400.0

const BIG_SPEED = SPEED*0.6
const BIG_SCALE = SMALL_SCALE*4
const BIG_JUMP_VELOCITY = JUMP_VELOCITY*1.5
const BIG_JUMP_SQUISH = JUMP_SQUISH*0.75
const BIG_JUMP_IMPACT = JUMP_IMPACT*0.75

const FALL_SPEED = 1100
const FLYING_FALL_SPEED = 150

const SMALL_POLY = [Vector2(-2, -5), Vector2(2, -5), Vector2(2, 0), Vector2(-2, 0)]
const BIG_POLY   = [4*Vector2(-2, -5), 4*Vector2(2, -5), 4*Vector2(2, 0), 4*Vector2(-2, 0)]

const MAX_LIFE = 3

# Rumble:
const CAM_MAX_SPEED = 300
const CAM_MAX_POWER = 10
const RUMBLE_VOLUME = 80

signal entered_cam_state
signal exited_cam_state


func exp_decay(a, b, decay, dt):
	return b+(a-b)*exp(-decay*dt)


func quick_timer(wait_time, timeout_func, is_one_shot = true) -> Timer:
	var timer : Timer = Timer.new()
	timer.autostart = true
	timer.one_shot = is_one_shot
	timer.wait_time = wait_time
	timer.timeout.connect(timeout_func)
	timer.start()
	return timer

func any_input(actions : Array, use_just := false) -> bool:
	for action in actions:
		if use_just:
			if Input.is_action_just_pressed(action): return true
		else:
			if Input.is_action_pressed(action): return true
	return false
