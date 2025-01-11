extends CanvasLayer

@onready var pause = $VBoxContainer

func _ready():
	hide_func(false)

func hide_func(booler):
	pause.visible = booler
	$TextureRect.visible = booler
	$Restart.visible = booler
	$Back.visible = booler

func _process(delta):
	if not get_tree().paused and pause.visible:
		get_tree().paused = true
	if Input.is_action_just_pressed("ui_cancel"):
		pause()

func pause(new_pause_state = not get_tree().paused):
	get_tree().paused = new_pause_state
	hide_func(new_pause_state)

func _on_Restart_pressed():
	pause(false)
	MusicController.music_action("transition1")
	get_tree().change_scene_to_file("Stage.tscn")

func _on_Back_pressed():
	pause(false)
	MusicController.music_action("transition2")
	get_tree().change_scene_to_file("Titlescreen.tscn")
