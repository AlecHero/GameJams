extends Area2D


func _on_body_entered(body):
	if "HeartFruit" in body.inventory:
		var root = get_parent().get_parent().get_parent() # level_x / World / root
		root.set_level(root.get_level()+1)
		AudioController.sound_play("Woosh")
		self.queue_free()
