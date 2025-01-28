extends Node2D

var last_mouse_pos = Vector2.ZERO
const ROTATION_LERP = 6
@onready var pin: Sprite2D = $"../Pin"
#@onready var pin_mark: Sprite2D = $"../PinMark"
@onready var cursor_spear: Area2D = $"../CursorSpear"

var is_pinning = false
var pin_position = Vector2.ZERO
var mouse_velocities = [Vector2.ZERO]
var current_velocity = Vector2.ZERO


func _process(delta: float) -> void:
	if !is_pinning:
		current_velocity = Lib.mean(mouse_velocities)
		global_position = get_global_mouse_position()
	rotation = lerp_angle(rotation, current_velocity.angle(), ROTATION_LERP * delta)


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
				#pin_mark.global_position = pin_position
				pin.show()
				#pin_mark.show()
			else:
				is_pinning = false
				#pin_mark.hide()
				pin.hide()
