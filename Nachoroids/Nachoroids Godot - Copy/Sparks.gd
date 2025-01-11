extends Area2D

var velocity = Vector2(0, 0)
#var direction = Vector2()

func _process(_delta):
	if !$RoundSpark.emitting and !$HitSpark.emitting and !$NachoSplosion.emitting:
		self.queue_free()

func _physics_process(delta):
	position += velocity * delta
	velocity *= 0.99

func set_emitting(effect, dir_vector = Vector2(0.0, 0.0)):
	get_node(effect).process_material.direction.x = dir_vector.x
	get_node(effect).process_material.direction.y = dir_vector.y
	get_node(effect).emitting = true
	
func set_particles(effect, particle_amount):
	get_node(effect).amount = particle_amount
