extends Area2D

@onready var cursor = %Cursor
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D

@export var arc_radius = 500.0
@export var dmg = 10.0
@export var knockback = 1.0
@export var radius = 125.0


const ARROW_PATH = preload("res://cursor/ArrowPath.tscn")
var last_angle = 0
var angle_diff = 0
const MOVE_LERP = 7
const MOVE_LERP_SLOW = 7
var current_move_lerp = MOVE_LERP
var rot_delta_scale = 35
var last_mouse_pos = Vector2.ZERO
var last_dist = 0
var dist_diff = 1

var first_pin := true
var has_intersection := false
var intersection_point := Vector2.ZERO
var last_intersect_point := intersection_point
var arrow_path

func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var clamped_mouse_pos = Lib.clamp_to_circle(mouse_pos, cursor.pin_position, arc_radius)
	
	if cursor.is_pinning:
		current_move_lerp = MOVE_LERP_SLOW if dist_diff < 0 else MOVE_LERP
		
		var lerped_pos = lerp(global_position, mouse_pos, current_move_lerp * delta)
		var clamped_pos = Lib.clamp_to_circle(lerped_pos, cursor.pin_position, arc_radius)
		
		var dist = cursor.pin_position.distance_to(clamped_pos)
		dist_diff = last_dist - dist
		last_dist = dist
		
		global_position = clamped_pos
		
		if first_pin:
			first_pin = false
			var path_point = Lib.find_circle_ray_intersections(cursor.pin_position, arc_radius+radius, cursor.pin_position, cursor.current_velocity, cursor.pin_position)
			
			arrow_path = ARROW_PATH.instantiate()
			arrow_path.add_point(cursor.pin_position, 0)
			arrow_path.add_point(path_point, 1)
			get_parent().get_parent().add_child(arrow_path)
		
		intersection_point = Lib.find_circle_ray_intersections(mouse_pos, radius, cursor.pin_position, cursor.current_velocity, cursor.pin_position)
		if intersection_point == Vector2.INF:
			intersection_point = last_intersect_point
			has_intersection = false
		else:
			has_intersection = true
			last_intersect_point = intersection_point
		var lerped_angle = lerp_angle(rotation, clamped_mouse_pos.angle_to_point(intersection_point)+PI/2, rot_delta_scale * delta) 
		rotation = lerped_angle
		
		material.set_shader_parameter("f", -rotation+PI/4)
	else:
		first_pin = true
		if arrow_path != null:
			arrow_path.kill()
		rotation = cursor.rotation + PI/2
		global_position = mouse_pos
	
	lerp_scale()

func lerp_scale():
	if cursor.is_pinning and has_intersection and abs(get_global_mouse_position().distance_to(intersection_point) - radius) < 20:
		if not is_equal_approx(scale.x, 1.0):
			scale *= 1.1
			sprite.modulate.a = 1.0
			scale = clamp(scale, Vector2(0.1,0.1), Vector2.ONE)
		elif scale.x > 0.5:
			collision_polygon_2d.disabled = false
	else:
		collision_polygon_2d.disabled = true
		if not is_equal_approx(scale.x, 0.0):
			scale *= 0.9
			sprite.modulate.a *= 0.95
			scale = clamp(scale, Vector2.ZERO, Vector2.ONE)
