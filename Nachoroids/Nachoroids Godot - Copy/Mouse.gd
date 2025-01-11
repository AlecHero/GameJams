extends Node2D

onready var sprite = $Sprite

var mouse_pos = Vector2()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(_delta):
	mouse_pos = get_global_mouse_position()
	self.position = mouse_pos

func _on_CursorHue_value_changed(value):
	sprite.material.set_shader_param("Shift_Hue", value)
