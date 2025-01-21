extends Label

@onready var cursor: Area2D = $"../../CursorSpear"

func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	
	text = ""
	text += str(mouse_pos) + "\n"
	#text += str(cursor.angle_diff) + "\n"
	#text += str(cursor.dist_diff) + "\n"
