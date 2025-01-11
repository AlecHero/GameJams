extends AudioStreamPlayer

func music_action(action):
	$AnimationPlayer.play(action)

func sound_play(sound):
	get_node(sound).play()

func sound_stop(sound):
	get_node(sound).stop()


var music_paths = [
	"Chopin Minute Waltz.mp3",
	"Peer Gynt Anitra's Dance.mp3",
	"Saint-Saëns Aquarium.mp3",
	"Beethoven Symphony no. 5.mp3",
	#"Peer Gynt Morning Mood.mp3",
	#"Tchaikovsky Swan Lake.mp3",
	]
var current_song = "Peer Gynt Morning Mood.mp3"


func load_mp3(path):
	var file = FileAccess.open(path, FileAccess.READ)
	var sound = AudioStreamMP3.new()
	sound.data = file.get_buffer(file.get_length())
	return sound


func _on_finished():
	var waittime = randf_range(60, 60*3)
	var timer := Timer.new()
	timer.one_shot = true
	timer.autostart = true
	timer.wait_time = waittime
	timer.timeout.connect(_timer_Timeout)
	add_child(timer)


func _timer_Timeout():
	music_paths.erase(current_song)
	var song_pick = music_paths.pick_random()
	var song = load_mp3("Music & Sound/Music/" + song_pick)
	music_paths.append(current_song)
	current_song = song_pick
	
	AudioController.stream = song
	AudioController.playing = true
