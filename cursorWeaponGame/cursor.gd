extends Area2D


func _ready() -> void:
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	pass

@export var arc_radius = 100
@export var pin_radius = 50
var swing_factor = 5

@onready var sprite: Sprite2D = $Sprite2D

func clamp_to_circle(to, from, radius):
	var offset = to - from
	if offset.length() > arc_radius:
		offset = offset.normalized() * arc_radius
	return from + offset

var last_angle = 0
var angle_diff = 0

var has_been_out_of_pin_radius = false
var last_mouse_pos = Vector2.ZERO

func _process(delta: float) -> void:
	if is_pinning:
		var lerped_pos = lerp(current_line.points[1], get_global_mouse_position(), 0.035)
		var clamped_pos = clamp_to_circle(lerped_pos, pin_position, arc_radius)
		
		current_line.set_point_position(1, clamped_pos)
		global_position = clamped_pos
		
		angle_diff = angle_difference(last_angle, rotation)
		last_angle = rotation
		
		sprite.rotation = -angle_diff * swing_factor
		
		#var offset = position - pin_position
		#if offset.length() < pin_radius:
			#if has_been_out_of_pin_radius:
				#offset = offset.normalized() * pin_radius
				#Input.warp_mouse(pin_position + offset)
		#else:
			#has_been_out_of_pin_radius = true
		var lerped_angle = lerp_angle(rotation, (current_line.points[1] - current_line.points[0]).angle()+PI/2, 0.1) 
		print(lerped_angle)
		rotation = lerped_angle
	else:
		
		if last_mouse_pos != get_global_mouse_position():
			rotation = lerp_angle(rotation, (get_global_mouse_position() - last_mouse_pos).angle()+PI/2, 0.1)
			last_mouse_pos = get_global_mouse_position()
		
		global_position = get_global_mouse_position()


func _physics_process(delta: float) -> void:
	pass
	#if is_pinning:
		#global_position = clamp_to_circle(get_global_mouse_position(), pin_position, arc_radius)
	#else:
	#global_position = get_global_mouse_position()


var is_pinning = false
var pin_position = Vector2.ZERO
var current_line = null

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if event.pressed:
				pin_position = global_position
				## ADD LINE DEBUG
				var line = Line2D.new()
				line.add_point(pin_position, 0)
				line.add_point(pin_position, 1)
				line.width = 2
				current_line = line
				get_parent().add_child(current_line)
				## ROTATE SWORD
				is_pinning = true
				has_been_out_of_pin_radius = false
			else:
				is_pinning = false
				Input.warp_mouse(clamp_to_circle(position, pin_position, arc_radius))
				current_line.queue_free()
