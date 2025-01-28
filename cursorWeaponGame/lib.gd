extends Node


@onready var rng = RandomNumberGenerator.new()
func _ready() -> void:
	rng.seed = hash("cursorGame")


func lerp_shader_parameter(material, parameter, lerp_to, lerp_delta) -> void:
	var get_param = material.get_shader_parameter(parameter)
	material.set_shader_parameter(parameter, lerp(get_param, lerp_to, lerp_delta))


func pick_random(arr):
	return arr[rng.randi() % len(arr)]

func pick_weighted(dict):
	return dict.keys()[rng.rand_weighted(dict.values())]


func mul(arr, m):
	for i in len(arr):
		arr[i] *= m


func mean(arr):
	var sum
	if arr[0] is Vector2:
		sum = Vector2.ZERO
	else:
		sum = 0 
	var n := float(len(arr))
	for i in n:
		sum+=arr[i]
	return sum/n

func circle_encompassing_viewport(viewport_size) -> Dictionary:
	var center = viewport_size / 2
	var radius = viewport_size.length() / 2
	return {"center": center, "radius": radius}

func get_points_on_circle(center: Vector2, radius: float, n_points: int) -> Array:
	var points = []
	for i in range(n_points):
		var angle = i * (2 * PI / n_points)
		var x = center.x + radius * cos(angle)
		var y = center.y + radius * sin(angle)
		points.append(Vector2(x, y))
	return points


func rand_circle_position(circ):
	var rand_angle = rng.randf_range(0, 2*PI)
	return circ["radius"] * Vector2(cos(rand_angle), sin(rand_angle)) + circ["center"]

func clamp_to_circle(to, from, radius):
	var offset = to - from
	if offset.length() > radius:
		offset = offset.normalized() * radius
	return from + offset


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
