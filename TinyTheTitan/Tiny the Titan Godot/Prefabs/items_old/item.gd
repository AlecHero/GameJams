extends Area2D

@export var item_name = "item"
@onready var player = get_parent().get_parent().get_node("Player")
var vol_max = 0

func _process(_delta):
	var has_item = item_name in player.inventory
	visible = not has_item
	$Rumble.volume_db = 20 if not has_item else -100
	
	if not has_item:
		var dist = (global_position.distance_to(player.position))
		var dist_ratio = 1-dist/900
		print(dist)
		player.rumble_dist = clamp(dist, 0., 900.)
		if dist < 900:
			if not has_item: AudioServer.set_bus_volume_db(1, -30*dist_ratio)
			else: AudioServer.set_bus_volume_db(1, lerp(AudioServer.get_bus_volume_db(1), 0.0, 0.05))
	else:
		player.rumble_dist = 900.

func _on_body_entered(body):
	if body == player and (item_name not in body.inventory):
		body.receive_item(item_name)
		body.update_checkpoint(global_position)
		Audio.play("ItemPickup")
