extends Area2D

var col_to_frame = {"Cyan":32, "Magenta":33, "Yellow":34, "Black":35}
@export_enum("Cyan", "Magenta", "Yellow", "Black") var color := "Cyan"
@onready var sprite = $Sprite2D


func _ready():
	#self.material.set_shader_parameter("do_rainbow", color)
	sprite.frame = col_to_frame[color]


func _on_body_entered(body):
	AudioController.sound_play("RainbowPickup")
	body.add_to_inventory(color)
	self.queue_free()
