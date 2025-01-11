extends Area2D

@export var point_reward = 1
@export_enum("PointPickup", "PointPickup3x") var point_sound: String

func _on_body_entered(body):
	body.update_points(point_reward)
	AudioController.sound_play(point_sound)
	self.queue_free()
