extends Area2D

@onready var cursor = %Cursor
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D

@export var arc_radius = 100.0
@export var dmg = 4.0
@export var knockback = 1.0

var current_dmg = dmg
var current_knockback = knockback

const HIDE_FACTOR = 20.0
const SWING_FACTOR = 5
const DIR_FACTOR = 28
const MOVE_LERP = 6
const ROT_LERP = 35
var last_angle = 0
var angle_diff = 0
var last_mouse_pos = Vector2.ZERO
var velocity_factor := 0.0


var angle_differences = [0]
var last_angle_diff = 0
var direction_change_debuff_t := 1.0

func _process(delta: float) -> void:
	if cursor.is_pinning:
		# Lerped Movement
		var lerped_pos = lerp(global_position, get_global_mouse_position(), MOVE_LERP * delta)
		var clamped_pos = Lib.clamp_to_circle(lerped_pos, cursor.pin_position, arc_radius)
		global_position = clamped_pos
		
		# Lerped Rotation
		var lerped_angle = lerp_angle(rotation, (global_position - cursor.pin_position).angle()+PI/4, min(1.0, ROT_LERP * delta)) 
		
		rotation = lerped_angle
		
		# Delayed Swing
		angle_diff = clamp(angle_difference(last_angle, rotation), -.2, .2)
		angle_differences.push_front(abs(angle_diff))
		Lib.mul(angle_differences, direction_change_debuff_t)
		
		if len(angle_differences) > 32:
			angle_differences.pop_back()
			if sign(angle_diff) != sign(last_angle_diff):
				direction_change_debuff_t = 0.0
			direction_change_debuff_t = lerp(direction_change_debuff_t, 1.0, delta*30)
			
			var sorted = angle_differences.duplicate()
			sorted.sort()
			velocity_factor = clamp(Lib.mean(sorted.slice(24, 31)) * 10, 0.0, 1.0)
		
		if velocity_factor > 0.5: # buff
			current_dmg = dmg * 1.25
			current_knockback = knockback * 1.5
		else: # debuff
			current_dmg = dmg * clamp(velocity_factor * 2.0, 0.1, 0.5)
			current_knockback = knockback * clamp(velocity_factor * 2.0, 0.0, 0.5)
		
		
		last_angle_diff = angle_diff
		last_angle = rotation
		sprite.rotation = -angle_diff * SWING_FACTOR
		
		var dir_factor = material.get_shader_parameter("dir_factor")
		if angle_diff != 0.0:
			dir_factor = clamp(lerp(dir_factor, sign(angle_diff), min(1.0, delta * DIR_FACTOR)), -1.0, 1.0)
			material.set_shader_parameter("dir_factor", dir_factor)
		material.set_shader_parameter("f", -rotation)
		
	else:
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
