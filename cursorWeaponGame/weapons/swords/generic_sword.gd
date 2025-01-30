extends Area2D

@onready var cursor: Node2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D

@export var arc_radius = 100.0
@export var dmg = 3.0
@export var knockback = 1.0

var current_dmg = dmg
var current_knockback = knockback

@export var SWING_FACTOR = 4.0 # 5 how stiff the rotation is
@export var MOVE_LERP = 7.0 # 6 how quickly the node moves
@export var ROT_LERP = 45.0 # 35 how quickly the node orientates itself

@export var is_hammer := false
@export var sword_type : Lib.SWORD_TYPES = 0
@export var lightning_chain_number := 6

const HIDE_FACTOR = 20.0 # how quickly the sprite fades
const DIR_FACTOR = 28 # how quickly the sprite "flips" on dir change


var last_angle = 0
var angle_diff = 0
var last_mouse_pos = Vector2.ZERO
var velocity_factor := 0.0

var angle_differences = [0]
var last_angle_diff = 0
var direction_change_debuff_t := 1.0


const VOLUME_MID = -45
const VOLUME_SILENT = -100
const VOLUME_DIFF = 16
@onready var rumble: AudioStreamPlayer = $Rumble
var lerped_angle = rotation

var velocity := 0.0
func _process(delta: float) -> void:
	if cursor.is_pinning:
		# Lerped Movement
		var lerped_pos = lerp(global_position, get_global_mouse_position(), MOVE_LERP * delta)
		var clamped_pos = Lib.clamp_to_circle(lerped_pos, cursor.pin_position, arc_radius)
		global_position = clamped_pos
		
		# Lerped Rotation
		lerped_angle = lerp_angle(lerped_angle, (global_position - cursor.pin_position).angle()+PI/4, min(1.0, ROT_LERP * delta)) 
		if !is_hammer: rotation = lerped_angle
		
		# Delayed Swing
		angle_diff = clamp(angle_difference(last_angle, lerped_angle), -.2, .2)
		angle_differences.push_front(abs(angle_diff))
		Lib.mul(angle_differences, direction_change_debuff_t)
		var sorted_mean = 0.0
		if len(angle_differences) > 32:
			angle_differences.pop_back()
			if sign(angle_diff) != sign(last_angle_diff):
				direction_change_debuff_t = 0.0
			direction_change_debuff_t = lerp(direction_change_debuff_t, 1.0, delta*30)
			
			var sorted = angle_differences.duplicate()
			sorted.sort()
			sorted_mean = Lib.mean(sorted.slice(24, 31))
			velocity_factor = clamp(sorted_mean * 10, 0.0, 1.0)
		
		if velocity_factor > 0.5: # buff
			current_dmg = dmg * 1.25
			current_knockback = knockback * 1.5
		else: # debuff
			current_dmg = dmg * clamp(velocity_factor * 2.0, 0.1, 0.5)
			current_knockback = knockback * clamp(velocity_factor * 2.0, 0.0, 0.5)
		
		# AUDIO
		var curr_delta = delta*10.0
		if sorted_mean > 0.09:
			curr_delta = delta*7.0
		else:
			curr_delta = delta*2.0
		rumble.volume_db = lerp(rumble.volume_db, min(-100 + sorted_mean * 320, -30.0), curr_delta)
		rumble.pitch_scale = lerp(rumble.pitch_scale, 0.0 + sorted_mean * 10.0, curr_delta)
		
		last_angle_diff = angle_diff
		last_angle = lerped_angle
		if not is_hammer:
			sprite.rotation = -angle_diff * SWING_FACTOR
		else:
			if angle_diff > 0.08:
				velocity += delta
			elif angle_diff < -0.08:
				velocity -= delta
			else:
				velocity *= 1.0 - 0.0025
			velocity = clamp(velocity, -0.5, 0.5)
			if abs(velocity) > 0.1:
				velocity_factor = clamp(abs(velocity)*5.0, 0.0, 1.0)
			
			rotation += velocity
		
		var dir_factor = material.get_shader_parameter("dir_factor")
		if angle_diff != 0.0:
			dir_factor = clamp(lerp(dir_factor, sign(angle_diff), min(1.0, delta * DIR_FACTOR)), -1.0, 1.0)
			material.set_shader_parameter("dir_factor", dir_factor)
		material.set_shader_parameter("f", -rotation)
		
	else:
		rumble.volume_db = lerp(rumble.volume_db, -100.0, delta*3.0)
		rumble.pitch_scale = lerp(rumble.pitch_scale, 1.0, delta*3.0)
		
		collision_polygon_2d.disabled = true
		global_position = get_global_mouse_position()
	
	var alph = material.get_shader_parameter("alpha")
	if cursor.is_pinning:
		scale = lerp(scale, Vector2.ONE, delta * HIDE_FACTOR)
		material.set_shader_parameter("alpha", lerp(alph, 1.0, min(1.0, delta * HIDE_FACTOR)))
		collision_polygon_2d.disabled = false
	else:
		scale = lerp(scale, Vector2(0.25, 0.25), delta * HIDE_FACTOR)
		material.set_shader_parameter("alpha", lerp(alph, 0.0, min(1.0, delta * HIDE_FACTOR)))
		collision_polygon_2d.disabled = true
	scale = clamp(scale, Vector2.ZERO, Vector2.ONE)


func _input(event: InputEvent) -> void:
	if !is_processing(): return
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if !event.pressed:
				Input.warp_mouse(Lib.clamp_to_circle(global_position, cursor.pin_position, arc_radius))
