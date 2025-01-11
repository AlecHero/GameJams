extends Area2D

@onready var flag = $AnimatedSprite2D

var is_on = false

func _ready():
	flag.set_animation("rise")
	#flag.material.set_shader_parameter("rot_speed", 0)

#var weight = 4.0
#var do_bounce = false
#
#var runde1 = true

#func _process(delta):
	#if do_bounce:
		#var rot_speed = flag.material.get_shader_parameter("rot_speed")
		#print(rot_speed)
		#if rot_speed <= 1.8 and runde1:
			#flag.material.set_shader_parameter("rot_speed", lerp(float(rot_speed), 2.0, delta*32.0))
		#else:
			#runde1 = false
			#flag.material.set_shader_parameter("rot_speed", lerp(float(rot_speed), 0.0, delta))

func _on_body_entered(body):
	if body.name == "Player":
		if not is_on:
			flag.set_animation("rise")
			flag.play()
			$Bounce.play()
			is_on = true
		#runde1 = true
		#do_bounce = true
		body.update_checkpoint(global_position)

func _on_animated_sprite_2d_animation_looped():
	if flag.get_animation() == "rise":
		flag.stop()
		flag.set_animation("big")
		flag.play()
