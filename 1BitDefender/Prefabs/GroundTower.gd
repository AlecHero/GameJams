extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var damage_cd: Timer = $DamageCD

@export var damage := 1.0
@export var tower_type := "None"
@export var slow_factor := 1.0

var is_activated

func _ready() -> void:
	sprite.frame = randi_range(0,sprite.hframes-1)
	sprite.flip_h = bool(round(randf()))

func _process(delta: float) -> void:
	if tower_type == "Vine" and damage_cd.is_stopped():
		damage_cd.start()
		for area in get_overlapping_areas():
			if area.is_in_group("Enemies"):
				area.hit(area.current_life*damage, tower_type)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemies"):
		if tower_type == "Spikes":
			area.hit(damage, tower_type)
		if tower_type == "Vine":
			slow_factor = exp(-area.speed*3.0)
		area.slow_factor = slow_factor

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("Enemies"):
		area.slow_factor = 1.0
