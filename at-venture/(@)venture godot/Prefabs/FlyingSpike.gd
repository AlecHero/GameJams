extends Node2D

@export var speed := 1.0 # seconds

func _process(delta):
	$Path2D/PathFollow2D/Area2D/Sprite2D.rotate(delta * 2.5)

func _physics_process(delta):
	$Path2D/PathFollow2D.progress_ratio += delta * speed

func _on_area_2d_body_entered(body):
	body.attacked()
	AudioController.sound_play("Oof")
