extends Area2D

#@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@export var speed = 500
@export var pierce = 0
@export var damage = 3

func _ready() -> void:
	name = "PlayerProjectile"
	#animation_player.play("swing_particle")

func _process(delta: float) -> void:
	position += transform.x * delta * speed
	if position.x < 0.0 or position.y < 0.0 or position.y > 416 or position.x > 672:
		queue_free()

#func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	#if anim_name == "swing_particle":
		#queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemies"):
		area.hit(damage)
		pierce -= 1
		if pierce <= 0:
			queue_free()
