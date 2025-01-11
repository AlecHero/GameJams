extends Area2D

@onready var sprite = $Sprite2D

var velocity = Vector2()

func _physics_process(delta):
	position += velocity * delta
	
	

#	for i in get_slide_count():
#		var collision = get_slide_collision(i)
#		collision.collider.splode()
#		queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

#func _on_Bullet_body_entered(body):
#	body.splode()
#	queue_free()


func _on_Bullet_area_entered(area):
	area.splode()
	queue_free()
