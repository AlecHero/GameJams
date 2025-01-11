extends Node

var Nachoroid = load("res://Nachoroid.tscn")

onready var animation_player = $HUD/AnimationPlayer
onready var score_label = $HUD/BackPanel/ScoreCounter/VBoxContainer/Score

const SPEED_MAX = 250.0
const SPEED_MIN = 150.0

var current_lives = 3
var score = 0
var overheated = false

func _ready():
	randomize()
	$HUD/BackPanel/LifeCounter.frame = 0 #reset lives
	animation_player.play("Idle") #reset icon
	score_label.text = str(score) #reset score
	score = 0

func _process(_delta):
	$SadLayer/Overheat/ColorRect.material.set_shader_param("opacity", $HUD.heat_progress)

func UpdateScore(x):
	score += x
	score_label.text = str(score)

func _on_SpawnTimer_timeout():
	var nacho = Nachoroid.instance()
	add_child(nacho)
	nacho.connect("receive_points", self, "UpdateScore")
	
	var mob_spawn_location = get_node("Path2D/PathFollow2D")
	mob_spawn_location.offset = randi()
	
	nacho.position = mob_spawn_location.position #Get random position on spawnpath
	nacho.rotation = mob_spawn_location.rotation + PI / 2 #Add rand_range(-PI / 4, PI / 4) for randomness
	nacho.velocity += Vector2(rand_range(SPEED_MIN, SPEED_MAX), 0.0).rotated(nacho.rotation)

func _on_IncreaseDifficultyTimer_timeout():
	if $SpawnTimer.wait_time > 0.3:
		$SpawnTimer.wait_time *= 0.80

func _on_Spaceship_game_over():
	var dict = {
		"Current": true,
		"Score": score,
		"Time": $HUD.time_string,
		"Name": "ALEX"
	}
	General.add_score(dict)
