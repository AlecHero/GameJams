extends Line2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	modulate.a = 0.0
	animation_player.play("spawn")
	sprite.position = points[1]
	sprite.rotation = points[0].angle_to_point(points[1])

func kill():
	animation_player.play("kill")
