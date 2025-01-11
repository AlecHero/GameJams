extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@export var damage = 10
const SWING_SPEED = 20
var projectile_name = "PlayerSwing"
var pierce = 3

func _ready() -> void:
	animation_player.play("swing_particle")

func _process(delta: float) -> void:
	position += transform.x * delta * SWING_SPEED

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "swing_particle":
		AudioController.play("hit_swing")
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemies") and pierce > 0:
		pierce -= 1
		area.hit(damage, projectile_name)
