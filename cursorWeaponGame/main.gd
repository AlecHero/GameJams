extends Node2D

@onready var enemy_handler: Node2D = $EnemyHandler

func _ready() -> void:
	Music.music_player.play(enemy_handler.start_time)
	#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("ui_accept"):
		Engine.max_fps = 120 if Engine.max_fps == 10 else 10
