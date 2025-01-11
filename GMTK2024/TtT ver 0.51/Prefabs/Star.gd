extends Area2D

@onready var player = get_parent().get_parent().get_node_or_null("Player")
@export var star_id = 0

func _process(_delta):
	if player != null:
		var has_star = star_id in player.stars
		visible = not has_star
		$Rumble.volume_db = 10 if not has_star else -100

func _on_body_entered(body):
	if body == player and (star_id not in body.stars):
		body.receive_star(star_id)
		Audio.play("ItemPickup")
