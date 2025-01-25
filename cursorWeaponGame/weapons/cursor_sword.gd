extends Area2D

@onready var cursor = %Cursor
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D

@export var arc_radius = 100.0
@export var dmg = 4.0
@export var knockback = 0.6

const HIDE_FACTOR = 20.0
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
		print(rotation)
		print((global_position - cursor.pin_position).angle()+PI/4)
		print(max(0, ROT_LERP * delta))
		var lerped_angle = lerp_angle(rotation, (global_position - cursor.pin_position).angle()+PI/4, min(1.0, ROT_LERP * delta)) 
		
		rotation = lerped_angle
		
		# Delayed Swing
		angle_diff = clamp(angle_difference(last_angle, rotation), -.1, .1)
		last_angle = rotation
		sprite.rotation = -angle_diff * SWING_FACTOR
		
		var dir_factor = material.get_shader_parameter("dir_factor")
		if angle_diff != 0.0:
			dir_factor = clamp(lerp(dir_factor, sign(angle_diff), delta * DIR_FACTOR), -1.0, 1.0)
			material.set_shader_parameter("dir_factor", dir_factor)
		material.set_shader_parameter("f", -rotation)
	else:
		collision_polygon_2d.disabled = true
		global_position = get_global_mouse_position()
	
	var alph = material.get_shader_parameter("alpha")
	if cursor.is_pinning:
		scale = lerp(scale, Vector2.ONE, delta * HIDE_FACTOR)
		material.set_shader_parameter("alpha", lerp(alph, 1.0, delta * HIDE_FACTOR))
		collision_polygon_2d.disabled = false
	else:
		scale = lerp(scale, Vector2(0.25, 0.25), delta * HIDE_FACTOR)
		material.set_shader_parameter("alpha", lerp(alph, 0.0, delta * HIDE_FACTOR))
		collision_polygon_2d.disabled = true
	scale = clamp(scale, Vector2.ZERO, Vector2.ONE)


func _input(event: InputEvent) -> void:
	if !is_processing(): return
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if !event.pressed:
				Input.warp_mouse(Lib.clamp_to_circle(position, cursor.pin_position, arc_radius))
