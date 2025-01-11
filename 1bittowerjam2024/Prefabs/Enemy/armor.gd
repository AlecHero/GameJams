extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

var is_activated : bool = false
var start_time : float
var t : float = 0.0

func _ready() -> void:
	sprite.modulate.a = 0.0
	show()

func _process(delta: float) -> void:
	if is_activated:
		is_activated = false
		sprite.modulate.a = 1.0
		t = 0.0
	if t <= 1.5:
		sprite.material.set_shader_parameter("t", t)
		t += 2.0*delta
	else:
		sprite.modulate.a = lerp(sprite.modulate.a, 0.0, 0.05)
