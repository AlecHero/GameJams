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

@onready var health_slider: HSlider = %HealthSlider
@onready var speed_slider: HSlider = %SpeedSlider

var debug_section = preload("res://DebugSection.tscn")
var debug_list = {}


func _ready():
	debug_ui.hide()
	
	debug_list = {
		"fps": func(): return Engine.get_frames_per_second(),
		"enemy_count": func(): return enemy_handler.get_child_count(),
		#"current_life": func(): return life_ball.current_life,
		"": func(): return "",
		"current_weapon": func(): return self.current_weapon_instance.name,
		"weapon_dmg": func(): return self.current_weapon_instance.current_dmg,
		"weapon_knockback": func(): return self.current_weapon_instance.current_knockback,
		" ": func(): return "",
		"wave_progress": func(): return enemy_handler.wave_progress_index,
		"wave_list": func(): return enemy_handler.wave_list[min(len(enemy_handler.wave_list)-1, enemy_handler.wave_index)],
		#"clamped_mouse_pos": func(): return spear.clamped_mouse_pos,
		#"intersection_point": func(): return spear.intersection_point,
		#"diff": func(): return spear.intersection_point - spear.clamped_mouse_pos,
		#"angle_to_intersect": func(): return ((spear.intersection_point - spear.clamped_mouse_pos).angle()),
		#"direction_change_debuff_t": func(): return spear.direction_change_debuff_t,
		#"spear_collision": func(): return spear.collision_polygon_2d.disabled,
	}
	
	for property in debug_list:
		var sec = debug_section.instantiate()
		sec.property = property
		sec.state = debug_list[property]
		debug_container.add_child(sec)

@onready var _10_min: Sprite2D = $"Timer/VBoxContainer/HBoxContainer/Control/10min"
@onready var _10_min_2: Sprite2D = $"Timer/VBoxContainer/HBoxContainer/Control/10min2"
@onready var _1_min: Sprite2D = $"Timer/VBoxContainer/HBoxContainer/Control2/1min"
@onready var _1_min_2: Sprite2D = $"Timer/VBoxContainer/HBoxContainer/Control2/1min2"
@onready var _10_sec: Sprite2D = $"Timer/VBoxContainer/HBoxContainer/Control5/10sec"
@onready var _10_sec_2: Sprite2D = $"Timer/VBoxContainer/HBoxContainer/Control5/10sec2"
@onready var _1_sec: Sprite2D = $"Timer/VBoxContainer/HBoxContainer/Control4/1sec"
@onready var _1_sec_2: Sprite2D = $"Timer/VBoxContainer/HBoxContainer/Control4/1sec2"

var n = 0
var current_weapon_instance
func _process(_delta):
	var ticks = Time.get_ticks_msec() / 1000.0
	var sec = fmod(ticks, 60.0)
	var min = floor(ticks / 60.0)
	var sec1 = floori(sec) % 10
	var sec10 = floori(sec) / 10
	var min1 = floori(min) % 10
	var min10 = floori(min) / 10
	
	_1_sec.frame = sec1+1
	_1_sec_2.frame = sec1+1
	
	_10_sec.frame = sec10+1
	_10_sec_2.frame = sec10+1
	
	_1_min.frame = min1+1
	_1_min_2.frame = min1+1
	
	_10_min.frame = min10+1
	_10_min_2.frame = min10+1
	
	
	current_weapon_instance = cursor_handler.weapon_dict[cursor_handler.current_weapon]
	
	health_slider.value = 100 * (life_ball.current_life/life_ball.base_life)
	speed_slider.value = 100 * spear.velocity_factor
	
	debug_point.global_position = spear.intersection_point
	debug_point2.global_position = spear.path_point
	
	if Input.is_action_just_pressed("DEBUG"):
		debug_ui.visible = !debug_ui.visible
