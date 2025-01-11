extends Node

var first_play := true

func music_action(action):
	$AnimationPlayer.play(action)
	if action == "fade_in":
		get_node("TitleTheme").play()
