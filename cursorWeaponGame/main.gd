extends Node2D

func _ready() -> void:
	#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass



func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("ui_accept"):
		Engine.max_fps = 120 if Engine.max_fps == 10 else 10
