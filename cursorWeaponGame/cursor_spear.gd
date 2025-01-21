extends Area2D

@export var arc_radius = 500
@export var pin_radius = 50
var swing_factor = 5
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D

const ARROW_PATH = preload("res://ArrowPath.tscn")

@onready var cursor = %Cursor
@export var dmg = 10
@export var knockback = 1

func clamp_to_circle(to, from, radius):
	var offset = to - from
	if offset.length() > arc_radius:
		offset = offset.normalized() * arc_radius
	return from + offset

var last_angle = 0
var angle_diff = 0

const MOVE_LERP = 7
const MOVE_LERP_SLOW = 7
var current_move_lerp = MOVE_LERP

var rot_delta_scale = 35

var last_mouse_pos = Vector2.ZERO

var last_dist = 0
var dist_diff = 1


func find_circle_line_intersections(cirle_point, r, line_point, line_dir):
	var x0 = line_point.x
	var y0 = line_point.y
	var dx = line_dir.x
	var dy = line_dir.y
	var h = cirle_point.x
	var k = cirle_point.y
	
	var A = dx * dx + dy * dy
	var B = 2 * (dx * (x0 - h) + dy * (y0 - k))
	var C = (x0 - h) * (x0 - h) + (y0 - k) * (y0 - k) - r * r
	
	var discriminant = B * B - 4 * A * C
	
	if discriminant < 0:
		return Vector2.INF # No intersection
	elif discriminant == 0:
		var t = -B / (2 * A)
		return Vector2(x0 + t * dx, y0 + t * dy) # One intersection
	else:
		var sqrt_discriminant = sqrt(discriminant)
		var t1 = (-B + sqrt_discriminant) / (2 * A)
		var t2 = (-B - sqrt_discriminant) / (2 * A)
		return Vector2(x0 + t1 * dx, y0 + t1 * dy)
			  #Vector2(x0 + t2 * dx, y0 + t2 * dy)


func find_circle_ray_intersections(circle_point, r, line_point, line_dir, ray_start):
	var x0 = line_point.x
	var y0 = line_point.y
	var dx = line_dir.x
	var dy = line_dir.y
	var h = circle_point.x
	var k = circle_point.y
	
	# Compute quadratic coefficients
	var A = dx * dx + dy * dy
	var B = 2 * (dx * (x0 - h) + dy * (y0 - k))
	var C = (x0 - h) * (x0 - h) + (y0 - k) * (y0 - k) - r * r
	
	var discriminant = B * B - 4 * A * C
	
	if discriminant < 0:
		return Vector2.INF # No intersection
	elif discriminant == 0:
		var t = -B / (2 * A)
		var intersection = Vector2(x0 + t * dx, y0 + t * dy)
		return clamp_to_ray(intersection, ray_start, line_dir) # One clamped intersection
	else:
		var sqrt_discriminant = sqrt(discriminant)
		var t1 = (-B + sqrt_discriminant) / (2 * A)
		var t2 = (-B - sqrt_discriminant) / (2 * A)
		
		var intersect = Vector2(x0 + t1 * dx, y0 + t1 * dy)
		
		return clamp_to_ray(intersect, ray_start, line_dir)

# Helper function to clamp a point to a ray
func clamp_to_ray(intersection_point, ray_start, ray_direction):
	var x_int = intersection_point.x
	var y_int = intersection_point.y
	var x0 = ray_start.x
	var y0 = ray_start.y
	var dx = ray_direction.x
	var dy = ray_direction.y
	
	# Calculate the parameter t for the ray
	var dx2_dy2 = dx * dx + dy * dy # Squared magnitude of direction
	if dx2_dy2 == 0:
		return ray_start # Ray direction is zero vector
	
	var t = ((x_int - x0) * dx + (y_int - y0) * dy) / dx2_dy2
	
	# Clamp t to [0, infinity) to restrict to the ray
	t = max(t, 0)
	
	# Compute the clamped point on the ray
	var clamped_x = x0 + t * dx
	var clamped_y = y0 + t * dy
	
	return Vector2(clamped_x, clamped_y)

var first_pin := true
var has_intersection := false
var intersection_point := Vector2.ZERO
var last_intersect_point := intersection_point
var arrow_path
@export var radius = 125
func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var clamped_mouse_pos = clamp_to_circle(mouse_pos, cursor.pin_position, arc_radius)
	
	if cursor.is_pinning:
		current_move_lerp = MOVE_LERP_SLOW if dist_diff < 0 else MOVE_LERP
		
		var lerped_pos = lerp(cursor.current_arc_line.points[1], mouse_pos, current_move_lerp * delta)
		var clamped_pos = clamp_to_circle(lerped_pos, cursor.pin_position, arc_radius)
		
		var dist = cursor.pin_position.distance_to(clamped_pos)
		dist_diff = last_dist - dist
		last_dist = dist
		
		cursor.current_arc_line.set_point_position(1, clamped_pos)
		global_position = clamped_pos
		
		if first_pin:
			first_pin = false
			var path_point = find_circle_ray_intersections(cursor.pin_position, arc_radius+radius, cursor.pin_position, cursor.current_velocity, cursor.pin_position)
			arrow_path = ARROW_PATH.instantiate()
			arrow_path.add_point(cursor.pin_position, 0)
			arrow_path.add_point(path_point, 1)
			get_parent().get_parent().add_child(arrow_path)
		
		material.set_shader_parameter("f", rotation)
		
		intersection_point = find_circle_ray_intersections(mouse_pos, radius, cursor.pin_position, cursor.current_velocity, cursor.pin_position)
		if intersection_point == Vector2.INF:
			intersection_point = last_intersect_point
			has_intersection = false
		else:
			has_intersection = true
			last_intersect_point = intersection_point
		var lerped_angle = lerp_angle(rotation, (clamped_mouse_pos - intersection_point).angle()-PI/2, rot_delta_scale * delta) 
		rotation = lerped_angle
	else:
		first_pin = true
		if arrow_path != null:
			arrow_path.kill()
		rotation = cursor.rotation + PI/2
		global_position = mouse_pos
	
	lerp_scale()

func lerp_scale():
	if cursor.is_pinning and has_intersection:
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
	


#func _draw() -> void:
	#if cursor.current_arc_line != null:
		#draw_circle(Vector2.ZERO, radius, Color.WHITE, false, 1, true)
		#var x = intersection_point-get_global_mouse_position()
		#x = -global_position
		#print(intersection_point)
		#draw_circle(x, 80, Color.RED, true, 1.0, true)
