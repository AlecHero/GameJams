extends Node2D
@onready var tilemap_meta: TileMapLayer = $Meta
@onready var player = $Player
@onready var camera: Camera2D = %MainCamera

func _ready():
	$UI/DebugUI/DebugContainer/VBoxContainer/MousePixelButton.toggled.connect(_on_mouse_pixel_button_toggled)
	$UI/DebugUI/DebugContainer/VBoxContainer/ResetCamButton.pressed.connect(_on_reset_cam_button_pressed)
	$MousePixel.hide()
	tilemap_meta.modulate = Color(1,1,1,0)

func _process(_delta):
	if $MousePixel.visible:
		$MousePixel.position = 4 * round((player.get_global_mouse_position() - Vector2(2, 2)) / 4) + Vector2(2,2)
	
	if Input.is_action_just_pressed("slowmo"):
		if Engine.time_scale == 0.1:
			Engine.time_scale = 1
		else:
			Engine.time_scale = 0.1
	
	if Input.is_action_just_pressed("ui_cancel"): get_tree().quit()
	
	if Input.is_action_just_pressed("reset"): player.reset_progress()

func _on_mouse_pixel_button_toggled(toggled_on: bool) -> void:
	$MousePixel.visible = toggled_on

func _on_reset_cam_button_pressed() -> void:
	camera.zoom = Vector2(1,1)
