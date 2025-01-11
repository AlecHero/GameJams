extends Area2D


func _on_body_entered(body):
	AudioController.sound_play("HeartFruitPickup")
	body.inventory.append("HeartFruit")
	self.queue_free()
