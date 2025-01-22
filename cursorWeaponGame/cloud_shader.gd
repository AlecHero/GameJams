extends ColorRect

@onready var rng = RandomNumberGenerator.new()
var timer : Timer

func _ready() -> void:
	timer = Timer.new()
	timer.autostart = true
	timer.wait_time = 1.0
	timer.start()

var current_angle := 0.0
var current_speed := 10.0
func _on_timer_timeout() -> void:
	current_angle += rng.randf_range(-PI/2, PI/2) # change direction but only near to the prev direction
	var direction = Vector2(cos(current_angle), sin(current_angle))
	var new_waittime = rng.randi_range(15, 90)
	current_speed = clamp(current_speed * rng.randf_range(0.8, 1.2), 5.0, 15.0)
	
	material.set_shader_material("direction", direction)
	material.set_shader_material("speed", current_speed*0.001)
