extends Node2D
@onready var tilemap_meta: TileMapLayer = $Meta
@onready var player = $Player
@onready var player_cam = player.get_node("Camera2D")

@onready var init_position = player_cam.get_screen_center_position()

func _ready():
	tilemap_meta.modulate = Color(1,1,1,0)

func reset():
	player.reset_progress()

func _process(_delta):
	if Input.is_action_just_pressed("slowmo"):
		if Engine.time_scale == 0.1:
			Engine.time_scale = 1
		else:
			Engine.time_scale = 0.1
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("reset"):# and player.is_dead:
		reset()
	#var offset = -(player_cam.get_screen_center_position() - init_position) / 1152.
	#shaders.update_vignette_offset(offset)
