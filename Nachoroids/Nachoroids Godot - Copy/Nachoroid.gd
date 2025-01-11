extends Area2D

signal receive_points(points)

onready var sprite = $Sprite
onready var split_positions = [$Position1, $Position2, $Position3, $Position4]

var Nachoroid = load("res://Nachoroid.tscn")
var Stage = preload("res://Stage.tscn")
var Explosion = preload("res://Sparks.tscn")

var velocity = Vector2()
var can_split = true
var reward = 50
var sploded := false

func _physics_process(delta):
	position += velocity * delta
	self.rotate(0.1)

func make_explosion(booler, scaler = Vector2(1.0, 1.0)):
	var explosion = Explosion.instance()
	get_parent().add_child(explosion)
	explosion.position = position
	explosion.velocity = velocity
	explosion.scale = scaler
	explosion.set_emitting("NachoSplosion")
	if booler:
		explosion.set_particles("NachoSplosion", 5) #from 33

func splode():
	emit_signal("receive_points", reward)
	if can_split and !sploded:
		make_explosion(false)
		for i in split_positions:
			var nacho = Nachoroid.instance()
			nacho.connect("receive_points", get_parent(), "UpdateScore")
			
			nacho.scale = Vector2(0.33, 0.33)
			nacho.can_split = false
			nacho.global_position = i.global_position
			nacho.reward = 5
			get_tree().current_scene.call_deferred("add_child", nacho)
			
			#Set speed in a random direction
			var random_dir = rand_range(0, 2 * PI)
			nacho.velocity += Vector2(rand_range(200.0, 300.0), 0.0).rotated(random_dir)
	else:
		make_explosion(true, Vector2(0.33, 0.33))
	sploded = true
	queue_free()

func _on_Nachoroid_body_entered(body):
	if "Spaceship" in body.name: 
		body.hit()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

#func nacho_left_screen():
#	pass
#	if position >
