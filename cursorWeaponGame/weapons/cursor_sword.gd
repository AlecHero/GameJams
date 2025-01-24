extends Area2D

@onready var cursor = %Cursor
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D

@export var arc_radius = 100.0
@export var dmg = 4.0
@export var knockback = 0.6

const SWING_FACTOR = 5
const DIR_FACTOR = 28
const MOVE_LERP = 6
const ROT_LERP = 35
var last_angle = 0
var angle_diff = 0
var last_mouse_pos = Vector2.ZERO
func _process(delta: float) -> void:
	if cursor.is_pinning:
		# Lerped Movement
		var lerped_pos = lerp(global_position, get_global_mouse_position(), MOVE_LERP * delta)
		var clamped_pos = Lib.clamp_to_circle(lerped_pos, cursor.pin_position, arc_radius)
		global_position = clamped_pos
		
		# Lerped Rotation
		var lerped_angle = lerp_angle(rotation, (global_position - cursor.pin_position).angle()+PI/4, ROT_LERP * delta) 
		rotation = lerped_angle
		
		# Delayed Swing
		angle_diff = angle_difference(last_angle, rotation)
		last_angle = rotation
		sprite.rotation = -angle_diff * SWING_FACTOR
		var dir_factor = material.get_shader_parameter("dir_factor")
		if angle_diff != 0.0:
			print(delta)
			material.set_shader_parameter("dir_factor", lerp(dir_factor, sign(angle_diff), delta * DIR_FACTOR))
		
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
	if !is_processing(): return
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if !event.pressed:
				Input.warp_mouse(Lib.clamp_to_circle(position, cursor.pin_position, arc_radius))
