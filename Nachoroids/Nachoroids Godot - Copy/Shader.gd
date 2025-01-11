extends CanvasLayer

func _process(_delta):
	for i in get_children():
		if "Layer" in i.name:
			i.rect = Rect2(0, 0, OS.get_screen_size().x, OS.get_screen_size().y)
			i.get_node("ColorRect").set_anchors_preset(15)
