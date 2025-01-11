extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var damage = 10
var projectile_name = "Fireball"
var pierce := 5
@onready var random_num = randi_range(0, 10)

func _ready() -> void:
	animation_player.play("fireball")
	material.set_shader_parameter("rand", random_num)

func _physics_process(delta: float) -> void:
	position += transform.x * delta * 150

func _process(delta: float) -> void:
	sprite.rotation = 2*PI-rotation
	if global_position.x < -10 or global_position.y < -10:
		queue_free()
	elif global_position.x > 700 or global_position.y > 500:
		queue_free()

func queue_destroy():
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemies") and pierce > 0:
		pierce -= 1
		area.hit(damage, projectile_name)
		queue_destroy()
