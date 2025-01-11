extends Node

## MUSIC:
@onready var intro_song: AudioStreamPlayer = $Music/Songs/IntroSong
@onready var standard_song: AudioStreamPlayer = $Music/Songs/StandardSong

@onready var goblin_song: AudioStreamPlayer = $Music/Songs/GoblinSong
@onready var skeleton_song: AudioStreamPlayer = $Music/Songs/SkeletonSong
@onready var cyclops_song: AudioStreamPlayer = $Music/Songs/CyclopsSong
@onready var spirit_song: AudioStreamPlayer = $Music/Songs/SpiritSong
@onready var desert_song: AudioStreamPlayer = $Music/Songs/DesertSong
@onready var spider_song: AudioStreamPlayer = $Music/Songs/SpiderSong
@onready var robot_song: AudioStreamPlayer = $Music/Songs/RobotSong
@onready var devil_song: AudioStreamPlayer = $Music/Songs/DevilSong
@onready var song_nodes = [
	goblin_song,
	skeleton_song,
	cyclops_song,
	spirit_song,
	desert_song,
	spider_song,
	robot_song,
	devil_song,
]

## AMBIANCE:
@onready var goblin_ambiance: AudioStreamPlayer = $Music/Ambiance/GoblinAmbiance
@onready var skeleton_ambiance: AudioStreamPlayer = $Music/Ambiance/SkeletonAmbiance
@onready var cyclops_ambiance: AudioStreamPlayer = $Music/Ambiance/CyclopsAmbiance
@onready var spirit_ambiance: AudioStreamPlayer = $Music/Ambiance/SpiritAmbiance
@onready var desert_ambiance: AudioStreamPlayer = $Music/Ambiance/DesertAmbiance
@onready var spider_ambiance: AudioStreamPlayer = $Music/Ambiance/SpiderAmbiance
@onready var robot_ambiance: AudioStreamPlayer = $Music/Ambiance/RobotAmbiance
@onready var devil_ambiance: AudioStreamPlayer = $Music/Ambiance/DevilAmbiance
@onready var ambiance_nodes = [
	goblin_ambiance,
	skeleton_ambiance,
	cyclops_ambiance,
	spirit_ambiance,
	desert_ambiance,
	spider_ambiance,
	robot_ambiance,
	devil_ambiance,
]

## SFX:
@onready var metal_1: AudioStreamPlayer = $SFX/metal1
@onready var metal_2: AudioStreamPlayer = $SFX/metal2
@onready var arrow_1: AudioStreamPlayer = $SFX/arrow1
@onready var swing_1: AudioStreamPlayer = $SFX/swing1
@onready var thud_1: AudioStreamPlayer = $SFX/thud1
@onready var thud_2: AudioStreamPlayer = $SFX/thud2
@onready var coin_1: AudioStreamPlayer = $SFX/coin1
@onready var monster_1: AudioStreamPlayer = $SFX/monster1
@onready var monster_2: AudioStreamPlayer = $SFX/monster2
@onready var monster_3: AudioStreamPlayer = $SFX/monster3
@onready var monster_4: AudioStreamPlayer = $SFX/monster4
@onready var ghost_1: AudioStreamPlayer = $SFX/ghost1
@onready var bones_1: AudioStreamPlayer = $SFX/bones1
@onready var bones_2: AudioStreamPlayer = $SFX/bones2
@onready var bonk_1: AudioStreamPlayer = $SFX/bonk1
@onready var bonk_2: AudioStreamPlayer = $SFX/bonk2
@onready var bonk_3: AudioStreamPlayer = $SFX/bonk3
@onready var wave_1: AudioStreamPlayer = $SFX/wave1


enum SONGS {
	GOBLIN, SKELETON, CYCLOPS, SPIRIT, DESERT, SPIDER, ROBOT, DEVIL, INTRO, STANDARD,
}

const MUTED = -80.0
const MUSIC_TRANSITION_SPEED = 0.5

var init_song_volumes : Array[float] = []
var init_ambiance_volumes : Array[float] = []

var current_song : AudioStreamPlayer
var current_ambiance : AudioStreamPlayer
var prev_song : AudioStreamPlayer

var is_in_transition := false

var current_type : Enemy.BEAST_TYPES = -1:
	set(new_type):
		if new_type != current_type or !current_song.playing:
			is_in_transition = true
			play_song_next = false
			
			prev_song = current_song
			
			current_song = song_nodes[new_type]
			current_ambiance = ambiance_nodes[new_type]
			
			current_song.volume_db = MUTED
			current_ambiance.volume_db = MUTED
			
			current_song.play()
			current_type = new_type

func _ready() -> void:
	Util.scene_changed.connect(func(beast_type): current_type = beast_type)
	
	for song in song_nodes:
		init_song_volumes.append(song.volume_db)
	for ambiance in ambiance_nodes:
		init_ambiance_volumes.append(ambiance.volume_db)
	
	current_song = standard_song
	current_ambiance = goblin_ambiance
	prev_song = goblin_song

func is_equal(a, b):
	return round(a) == round(b)

var has_played_ambiance := false
var is_ambiance_forced_stop := false
var is_ambiance_waiting := false
var is_song_waiting := false
var play_song_next := false
func _process(delta: float) -> void:
	if current_song.playing:
		if !is_equal(current_song.volume_db, init_song_volumes[current_type]):
			current_song.volume_db = lerp(current_song.volume_db, init_song_volumes[current_type], delta*MUSIC_TRANSITION_SPEED)
		else: is_in_transition = false
	
	if prev_song.playing:
		if !is_equal(prev_song.volume_db, MUTED):
			prev_song.volume_db = lerp(prev_song.volume_db, MUTED, delta*MUSIC_TRANSITION_SPEED)
		else:
			prev_song.stop()
	
	if current_ambiance.playing:
		if is_ambiance_forced_stop:
			if !is_equal(current_ambiance.volume_db, MUTED):
				current_ambiance.volume_db = lerp(current_ambiance.volume_db, MUTED, delta*MUSIC_TRANSITION_SPEED)
			else:
				current_ambiance.stop()
		else:
			if !is_equal(current_ambiance.volume_db, init_ambiance_volumes[current_type]):
				current_ambiance.volume_db = lerp(current_ambiance.volume_db, init_ambiance_volumes[current_type], delta*MUSIC_TRANSITION_SPEED)
	
	if !is_in_transition and !current_song.playing and !is_ambiance_waiting and !current_ambiance.playing:
		if !play_song_next:
			is_ambiance_waiting = true
			play_song_next = true
			var timer_wait = Util.quick_timer(randf_range(0, 5), func():
				is_ambiance_waiting = false
				is_ambiance_forced_stop = false
				current_ambiance.volume_db = MUTED
				current_ambiance.play()
				var timer_play = Util.quick_timer(randf_range(60, 120), func(): is_ambiance_forced_stop = true)
				add_child(timer_play))
			add_child(timer_wait)
		else:
			is_in_transition = true
			play_song_next = false
			var timer_wait = Util.quick_timer(randf_range(0, 5), func():
				is_song_waiting = false
				current_song.volume_db = MUTED
				current_song.play())
			add_child(timer_wait)


func play(sound) -> void:
	match sound:
		"hit_enemy":
			var audio_pitch = randf_range(0.80, 1.5)
			thud_2.pitch_scale = audio_pitch
			thud_2.play()
		"hit_metal":
			var audio_pitch = randf_range(0.75, 1.5)
			if randf() < 0.5:
				metal_1.pitch_scale = audio_pitch
				metal_1.play()
			else:
				metal_2.pitch_scale = audio_pitch
				metal_2.play()
		"hit_arrow":
			var audio_pitch = randf_range(0.90, 1.5)
			arrow_1.pitch_scale = audio_pitch
			arrow_1.play()
		"hit_swing":
			var audio_pitch = randf_range(0.8, 2.0)
			swing_1.pitch_scale = audio_pitch
			swing_1.play()
		"hit_ballista":
			var audio_pitch = randf_range(0.50, 1.)
			thud_1.pitch_scale = audio_pitch
			thud_1.play()
		
		"coin_drop":
			var audio_pitch = randf_range(1., 2.)
			coin_1.pitch_scale = audio_pitch
			coin_1.play()
			
		"monster_death":
			var audio_pitch = randf_range(.6, 1.6)
			var monster_death = [
				monster_1, monster_2, monster_3, monster_4,
			].pick_random()
			monster_death.pitch_scale = audio_pitch
			monster_death.play()
		"spirit_death":
			var audio_pitch = randf_range(.55, 1.)
			ghost_1.pitch_scale = audio_pitch
			ghost_1.play()
			
		"skeleton_death":
			var audio_pitch = randf_range(0.75, 1.80)
			var skeleton_death = [
				bones_1, bones_2,
			].pick_random()
			skeleton_death.pitch_scale = audio_pitch
			skeleton_death.play()
		"repair":
			var audio_pitch = randf_range(0.8, 1.10)
			var hammer_bonk = [
				bonk_1, bonk_2, bonk_3
			].pick_random()
			hammer_bonk.pitch_scale = audio_pitch
			hammer_bonk.play()
		"next_wave":
			wave_1.play()
