extends Node
@onready var mouse = $Mouse/Mouse


@onready var menu_start: = $Menu/Menu/VBoxContainer/MarginContainer/Start
@onready var menu_slider = $Menu/Menu/VBoxContainer/MarginContainer/CursorHue/Slider
@onready var menu_highscore = $Menu/Menu/VBoxContainer/MarginContainer/Highscore

@onready var menu_slider_label = $Menu/Menu/VBoxContainer/MarginContainer/CursorHue/Label
@onready var button_quit = $Menu/Options/QuitButton

var sans = load("res://Fonts/SansFont.tres")
var sans_bold = load("res://Fonts/SansFontBold.tres")
var should_reset_music = true


func _ready():
	button_quit.hide()
	mouse.show()
	
	if MusicController.first_play:
		MusicController.music_action("fade_in")
		MusicController.first_play = false

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	
	if menu_start.is_hovered():
		menu_start.add_theme_font_override("font", sans_bold)
	else:
		menu_start.add_theme_font_override("font", sans)

	if menu_highscore.is_hovered():
		menu_highscore.add_theme_font_override("font", sans_bold)
	else:
		menu_highscore.add_theme_font_override("font", sans)

func _on_CursorHue_mouse_entered():
	menu_slider_label.add_theme_font_override("font", sans_bold)
func _on_CursorHue_mouse_exited():
	menu_slider_label.add_theme_font_override("font", sans)

func _on_Start_pressed():
	MusicController.music_action("transition1")
	get_tree().change_scene_to_file("Stage.tscn")

func _on_Highscore_pressed():
	get_tree().change_scene_to_file("Highscore.tscn")


func _on_MusicButton_toggled(button_pressed):
	AudioServer.set_bus_mute(1, button_pressed)

func _on_SFXButton_toggled(button_pressed):
	AudioServer.set_bus_mute(2, button_pressed)

func _on_QuitButton_pressed():
	get_tree().quit()
