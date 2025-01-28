extends CanvasLayer

@export var main : Node2D
@export var cursor_handler : Node2D
@export var enemy_handler : Node2D

@onready var cursor = cursor_handler.get_node("%Cursor")
@onready var life_ball = cursor_handler.get_node("%LifeBall")
@onready var sword = cursor_handler.get_node("%CursorSword")
@onready var spear = cursor_handler.get_node("%CursorSpear")

@onready var debug_point = $point
@onready var debug_point2 = $point2
@onready var debug_ui = %DebugUI
@onready var debug_container = $DebugUI/DebugContainer

@onready var health_slider: HSlider = $MarginContainer/VBoxContainer/HealthSlider
@onready var speed_slider: HSlider = $MarginContainer/VBoxContainer/SpeedSlider

var debug_section = preload("res://DebugSection.tscn")
var debug_list = {}


func _ready():
	debug_list = {
		"fps": func(): return Engine.get_frames_per_second(),
		"enemy_count": func(): return enemy_handler.get_child_count(),
		"current_life": func(): return life_ball.current_life,
		"": func(): return "",
		"path_angle": func(): return spear.path_angle,
		"clamped_mouse_pos": func(): return spear.clamped_mouse_pos,
		"intersection_point": func(): return spear.intersection_point,
		"diff": func(): return spear.intersection_point - spear.clamped_mouse_pos,
		"angle_to_intersect": func(): return ((spear.intersection_point - spear.clamped_mouse_pos).angle()),
		"direction_change_debuff_t": func(): return spear.direction_change_debuff_t,
		"spear_collision": func(): return spear.collision_polygon_2d.disabled,
	}
	
	for property in debug_list:
		var sec = debug_section.instantiate()
		sec.property = property
		sec.state = debug_list[property]
		debug_container.add_child(sec)

var n = 0
func _process(_delta):
	health_slider.value = 100 * (life_ball.current_life/life_ball.base_life)
	speed_slider.value = 100 * spear.velocity_factor
	
	debug_point.global_position = spear.intersection_point
	debug_point2.global_position = spear.path_point
	
	if Input.is_action_just_pressed("DEBUG"):
		debug_ui.visible = !debug_ui.visible
