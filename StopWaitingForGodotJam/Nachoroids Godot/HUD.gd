extends CanvasLayer

@onready var spaceship = get_node("../Spaceship")
@onready var animation_player = $AnimationPlayer

var score := 0
var overheated := false
var heat_boring := 0.0
var heat_progress := 0.0

var time := 0.0
var minutes := 0.0
var seconds := 0.0

var string_min = "00"
var string_sec = "00"
var time_string = ""

var text_piece := 0


func _ready():
	$Tutorial.show()
	time = 0

func _process(delta):
	ClockChange(delta)
	AlienLoop()
	$BackPanel/LifeCounter.frame = 3 - spaceship.current_life
	
	if Input.is_action_just_pressed("Shoot") and $BackPanel/Button.is_hovered():
		$BackPanel/Button.disabled = false
		$CloseLidTimer.start()
	if $BackPanel/Button.is_hovered():
		$CloseLidTimer.start()

func _on_CloseLidTimer_timeout():
	$BackPanel/Button.disabled = true

func _on_Button_pressed():
	MusicController.music_action("transition2")
	get_tree().change_scene_to_file("Titlescreen.tscn")

func ClockChange(delta):
	if !spaceship.is_dead:
		time += delta
		minutes = floor(time / 60)
		seconds = floor(time) - minutes * 60
		
		if minutes < 10:
			string_min = "0" + str(minutes)
		else:
			string_min = str(minutes)
		if seconds < 10:
			string_sec = "0" + str(seconds)
		else:
			string_sec = str(seconds)
		time_string = string_min + ":" + string_sec
		$BackPanel/TimeCounter/Label.text = time_string

func AlienLoop():
	if spaceship.is_shooting:
		$BackPanel/Alien.frame = 1 + spaceship.num % 2
	elif spaceship.is_dead:
		animation_player.play("Dead")
	else:
		animation_player.play("Idle")

func _on_RemoveTutorialTimer_timeout():
	$Tutorial.hide()

@export var heater: Curve

func _on_Spaceship_overheat(heat_num, cooldown_bool):
	$BackPanel/Overheat.value = heat_num
	heat_boring = heat_num / $BackPanel/Overheat.max_value
	heat_progress = heater.sample(heat_boring)
	overheated = cooldown_bool
	if cooldown_bool:
		$BackPanel/Sprite2D.frame = 1
	else:
		$BackPanel/Sprite2D.frame = 0
