extends CharacterBody2D

var last_mouse_pos = Vector2.ZERO
const ROTATION_LERP = 6
@onready var pin: Sprite2D = $"../Pin"
@onready var pin_mark: Sprite2D = $"../PinMark"

func mean(arr):
	var sum := Vector2.ZERO
	var n := len(arr)
	for i in n:
		sum+=arr[i]
	return sum/n

@onready var cursor_spear: Area2D = $"../CursorSpear"

func _process(delta: float) -> void:
	if !is_pinning:
		current_velocity = mean(mouse_velocities)
		global_position = get_global_mouse_position()
	else:
		pass
		#current_dir_line.set_point_position(1, pin_position+current_velocity*100)
	
	rotation = lerp_angle(rotation, current_velocity.angle(), ROTATION_LERP * delta)


var current_arc_line = null
var current_dir_line = null
func add_lines():
	var arc_line = Line2D.new()
	arc_line.add_point(pin_position, 0)
	arc_line.add_point(pin_position, 1)
	arc_line.width = 2
	current_arc_line = arc_line
	get_parent().add_child(current_arc_line)
	
	#var dir_line = Line2D.new()
	#dir_line.add_point(pin_position, 0)
	#dir_line.add_point(pin_position, 1)
	#dir_line.width = 2
	#current_dir_line = dir_line
	#get_parent().add_child(current_dir_line)


var is_pinning = false
var pin_position = Vector2.ZERO
var mouse_velocities = [Vector2.ZERO]
var current_velocity = Vector2.ZERO
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_velocities.push_front(event.velocity)
		if len(mouse_velocities) > 15:
			mouse_velocities.pop_back()
	
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if event.pressed:
				is_pinning = true
				pin_position = global_position
				pin.global_position = pin_position
				pin_mark.global_position = pin_position
				pin.show()
				pin_mark.show()
				add_lines()
			else:
				is_pinning = false
				pin_mark.hide()
				pin.hide()
				current_arc_line.queue_free()
				#current_dir_line.queue_free()
