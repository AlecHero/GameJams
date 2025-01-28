extends Area2D

@onready var cursor = %Cursor
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D

@export var arc_radius = 500.0
@export var dmg = 10.0
@export var knockback = 0.8
@export var radius = 110.0
@export var penetration = 0.0

var current_dmg = dmg
var current_knockback = knockback

const DMG_VELOCITY_BUFF = 3.0
const KNOCKBACK_VELOCITY_BUFF = 2.0

const HIDE_FACTOR = 20.0
const ARROW_PATH = preload("res://cursor/ArrowPath.tscn")
var last_angle = 0
var angle_diff = 0
const MOVE_LERP = 7
const MOVE_LERP_SLOW = 7
const ROT_LERP = 50

var current_move_lerp = MOVE_LERP
var last_mouse_pos = Vector2.ZERO
var last_dist = 0
var dist_diff = 1

var first_pin := true
var has_intersection := false
var intersection_point := Vector2.ZERO
var last_intersection_point := intersection_point
var arrow_path

var path_angle = Vector2.ZERO
var intersection_angle = Vector2.ZERO
var clamped_mouse_pos = Vector2.ZERO
var path_point = Vector2.ZERO

var dist_differences = [0.0]
var direction_change_debuff_t := 1.0
var last_direction := false
var velocity_factor = 0.0

var is_too_far := false

func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	clamped_mouse_pos = Lib.clamp_to_circle(mouse_pos, cursor.pin_position, arc_radius)
	
	if cursor.is_pinning:
		var lerped_pos = lerp(global_position, mouse_pos, current_move_lerp * delta)
		var clamped_pos = Lib.clamp_to_circle(lerped_pos, cursor.pin_position, arc_radius)
		global_position = clamped_pos
		
		#current_move_lerp = MOVE_LERP_SLOW if dist_diff < 0 else MOVE_LERP
		#var dist = cursor.pin_position.distance_to(clamped_pos)
		#dist_diff = last_dist - dist
		#last_dist = dist
		
		if first_pin:
			first_pin = false
			path_point = Lib.find_circle_ray_intersections(cursor.pin_position, arc_radius+radius, cursor.pin_position, cursor.current_velocity, cursor.pin_position)
			
			path_angle = cursor.pin_position.angle_to_point(path_point)
			
			arrow_path = ARROW_PATH.instantiate()
			arrow_path.add_point(cursor.pin_position, 0)
			arrow_path.add_point(path_point, 1)
			get_parent().get_parent().add_child(arrow_path)
		
		intersection_point = Lib.find_circle_ray_intersections(mouse_pos, radius, cursor.pin_position, cursor.current_velocity, cursor.pin_position)
		
		var last_dist = cursor.pin_position.distance_to(last_intersection_point)
		var curr_dist = cursor.pin_position.distance_to(intersection_point)
		var dist_diff = last_dist - curr_dist
		dist_differences.push_front(-dist_diff)
		Lib.mul(dist_differences, direction_change_debuff_t)
		var curr_direction = Lib.mean(dist_differences) < 0
		
		if len(dist_differences) > 64:
			dist_differences.pop_back()
			if curr_direction != last_direction:
				direction_change_debuff_t = 0.0
			direction_change_debuff_t = lerp(direction_change_debuff_t, 1.0, delta*15)
			velocity_factor = lerp(velocity_factor, clamp(Lib.mean(dist_differences)*2, 0.0, 1.0), delta * 8)
		
		last_direction = curr_direction
		collision_polygon_2d.disabled = is_too_far or (Lib.mean(dist_differences) < 0)
		
		current_dmg = dmg * velocity_factor * DMG_VELOCITY_BUFF
		current_knockback = knockback * velocity_factor * KNOCKBACK_VELOCITY_BUFF
		
		if intersection_point == Vector2.INF:
			intersection_point = last_intersection_point
			has_intersection = false
		else:
			has_intersection = true
			last_intersection_point = intersection_point
		
		#intersection_angle = (intersection_point - clamped_mouse_pos).angle()
		#var mid_angle = path_angle * 0.0 + intersection_angle * 1.0 + PI/2
		#var lerped_angle = lerp_angle(rotation, mid_angle, ROT_LERP * delta)
		rotation = path_angle+PI/2#lerped_angle
		material.set_shader_parameter("f", -rotation+PI/4)
	else:
		first_pin = true
		if arrow_path != null:
			arrow_path.kill()
		global_position = mouse_pos
	
	
	var alph = material.get_shader_parameter("alpha")
	var dist_cond = abs(mouse_pos.distance_to(intersection_point) - radius) < 25
	if cursor.is_pinning and dist_cond:
		scale = lerp(scale, Vector2.ONE, delta * HIDE_FACTOR)
		material.set_shader_parameter("alpha", lerp(alph, 1.0, delta * HIDE_FACTOR))
		is_too_far = false
	else:
		scale = lerp(scale, Vector2(0.25, 0.25), delta * HIDE_FACTOR)
		material.set_shader_parameter("alpha", lerp(alph, 0.0, delta * HIDE_FACTOR))
		is_too_far = true



func _input(event: InputEvent) -> void:
	if !is_processing(): return
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if !event.pressed:
				Input.warp_mouse(cursor.pin_position)
