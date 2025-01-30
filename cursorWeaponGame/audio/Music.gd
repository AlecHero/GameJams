extends Node

@onready var music_player: AudioStreamPlayer = $MusicPlayer
const wave_intro = preload("res://audio/music/Big Mojo.mp3")
const wave_skelly = preload("res://audio/music/Netherworld Shanty.mp3")
const wave_orc = preload("res://audio/music/Shamanistic.mp3")

const merchant_desert = preload("res://audio/music/Desert City.mp3")
const merchant_goofy = preload("res://audio/music/Goblin_Tinker_Soldier_Spy.mp3")
const merchant_gypsy = preload("res://audio/music/Gypsy Shoegazer No Voices.mp3")
const merchant_chill = preload("res://audio/music/Mystery Bazaar.mp3")
const desert_city = preload("res://audio/music/Hidden Wonders.mp3")
const low_life = preload("res://audio/music/Firebrand.mp3")


func _ready() -> void:
	Lib.wave_passed.connect(wave_passed)
	Lib.next_wave.connect(next_wave)
	Lib.start_wave.connect(next_wave)


func wave_passed():
	pass

func next_wave(wave_num):
	current_song = wave_num


enum SONG_TYPES { WAVE_INTRO, WAVE_SKELLY, WAVE_ORC, WAVE_CYCLOP, WAVE_HARVESTER, WAVE_PIG, WAVE_KNIGHT, LOW_LIFE, MERCHANT_DESERT}
@onready var song_dict = {
	SONG_TYPES.WAVE_INTRO : wave_intro,
	SONG_TYPES.WAVE_SKELLY : wave_skelly,
	SONG_TYPES.WAVE_ORC : wave_orc,
}

#SONG_TYPES.LOW_LIFE : low_life,
#SONG_TYPES.MERCHANT_DESERT : merchant_desert,

@onready var current_song := SONG_TYPES.WAVE_INTRO :
	set(new_song):
		if new_song != current_song:
			music_player.stream = song_dict[new_song]
			music_player.play()
			
			current_song = new_song

#var music_queue = [SONG_TYPES.MERCHANT_DESERT]

func _on_music_player_finished() -> void:
	Lib.wave_passed.emit()
	#current_song = music_queue.pop_front()
