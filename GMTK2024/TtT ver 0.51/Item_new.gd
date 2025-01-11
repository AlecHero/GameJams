extends Area2D

@export_enum("Ring", "Boots", "Wings", "Claws") var item_type: int
@onready var lookup = {
	0:"ring",
	1:"boots",
	2:"wings",
	3:"claws",
}
@onready var item_name = lookup[item_type]
@onready var player = get_parent().get_parent().get_node("Player")

func _process(_delta): visible = not item_name in player.inventory

func _on_body_entered(body):
	if body == player and (item_name not in body.inventory):
		body.receive_item(item_name)
		body.update_checkpoint(global_position)
		Audio.play("ItemPickup")
		$Rumble.volume_db = -100
