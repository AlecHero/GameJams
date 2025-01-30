extends Area2D

@export var upgrade_type := Upgrades.PICKUP_TYPES.HEART
@export var life_time := 5.0 # seconds


func _process(delta: float) -> void:
	match upgrade_type:
		Upgrades.PICKUP_TYPES.HEART:
			pass
