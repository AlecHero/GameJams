extends Node

func play(sound_name): get_node(sound_name).play()

@onready var animation_player = $AnimationPlayer
@onready var music = $MainTheme

var is_theme_playing = true

func music_play():
	animation_player.play("fade_in")

func _ready():
	if is_theme_playing: music_play()

func _on_main_theme_finished():
	var rng = RandomNumberGenerator.new()
	var wait_time = rng.randf_range(10,120)
	await get_tree().create_timer(wait_time).timeout
	if is_theme_playing: music_play()
