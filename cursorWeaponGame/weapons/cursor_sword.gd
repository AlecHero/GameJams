extends Area2D

@onready var cursor = %Cursor

@export var arc_radius = 100
@export var pin_radius = 50
var swing_factor = 5
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D

@onready var dmg = 4
@onready var knockback = 2

func clamp_to_circle(to, from, radius):
	var offset = to - from
	if offset.length() > arc_radius:
		offset = offset.normalized() * arc_radius
	return from + offset

const MOVE_LERP = 6
const ROT_LERP = 35

var last_angle = 0
var angle_diff = 0

var last_mouse_pos = Vector2.ZERO

func _process(delta: float) -> void:
	if cursor.is_pinning:
		# Lerped Movement
		var lerped_pos = lerp(cursor.current_arc_line.points[1], get_global_mouse_position(), MOVE_LERP * delta)
		var clamped_pos = clamp_to_circle(lerped_pos, cursor.pin_position, arc_radius)
		cursor.current_arc_line.set_point_position(1, clamped_pos)
		global_position = clamped_pos
		
		# Lerped Rotation
		var lerped_angle = lerp_angle(rotation, (cursor.current_arc_line.points[1] - cursor.current_arc_line.points[0]).angle()+PI/4, ROT_LERP * delta) 
		rotation = lerped_angle
		
		# Delayed Swing
		angle_diff = angle_difference(last_angle, rotation)
		last_angle = rotation
		sprite.rotation = -angle_diff * swing_factor
		var dir_factor = material.get_shader_parameter("dir_factor")
		if angle_diff != 0.0:
			material.set_shader_parameter("dir_factor", lerp(dir_factor, sign(angle_diff), 0.2))
		
		material.set_shader_parameter("f", -rotation)
	else:
		collision_polygon_2d.disabled = true
		global_position = get_global_mouse_position()
	
	lerp_scale()


func lerp_scale():
	if cursor.is_pinning:
		if scale != Vector2(1.0, 1.0):
			scale *= 1.1
			modulate.a = 1.0
		
		if scale.x > 0.7:
			collision_polygon_2d.disabled = false
	else:
		if scale != Vector2(0.2, 0.2):
			scale *= 0.9
			modulate.a *= 0.6
		
		if scale.x < 0.7:
			collision_polygon_2d.disabled = true
	
	scale = clamp(scale, Vector2(0.2,0.2), Vector2(1.0, 1.0))


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if !event.pressed:
				Input.warp_mouse(clamp_to_circle(position, cursor.pin_position, arc_radius))
