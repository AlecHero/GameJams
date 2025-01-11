extends CharacterBody2D

@onready var sprite = $Sprite2D
@onready var partic = $WalkParticle
@onready var camera = $Camera2D
@onready var root = get_parent().get_parent()
@onready var halftone = root.get_node_or_null("Shaders/Halftone").get_child(0)

const CAM_MAX_SPEED = 350
const CAM_MAX_POW = 20
const ANIM_SPEED = 20.0
const SPEED = 400.0
@export var RUMBLE_DISTANCE = 700.0

var is_moving := false
var is_fast := false

var inventory = []#["HeartFruit", "Cyan", "Magenta", "Yellow"]
var life := 2
var points := 0


func set_life(num:int) -> void:
	life = num
	emit_signal("update_ui_hp", life)
func get_life() -> int: return life

func set_pos(pos:Vector2) -> void: position = pos-Vector2(32,32)

func add_to_inventory(color: String) -> void: inventory.append(color)

signal update_ui_points(total_points)
func update_points(point_reward):
	points += point_reward
	emit_signal("update_ui_points", points)

signal update_ui_hp(life)
func attacked() -> void:
	if get_life()-1 == 0:
		death()
	else: 
		set_life(get_life()-1)
		$DeathTimer.start()
		set_collision_layer_value(2, false)

signal player_death
func death():
	points = 0
	emit_signal("player_death")
	emit_signal("update_ui_points", 0)
	var main = get_tree().get_root().get_node("Main")
	main.set_level(main.get_level())
	

func move_loop():
	var dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	is_moving = dir.length() > 0
	is_fast = Input.is_action_pressed("shift")
	
	if not is_moving and velocity.length() > 0: velocity *= 0.9
	elif is_fast: velocity = dir * SPEED * 1.5
	else: velocity = dir * SPEED
	move_and_slide()

func anim_loop():
	var anim_speed = ANIM_SPEED * (1+float(is_fast))
	sprite.material.set_shader_parameter("speed", float(is_moving) * anim_speed)
	partic.emitting = is_moving
	
	if is_fast:
		$WalkSound.pitch_scale = 2.5
		$WalkSound.volume_db = -4
	else:
		$WalkSound.pitch_scale = 2
		$WalkSound.volume_db = -5
		
	if is_moving and not $WalkSound.playing:
		$WalkSound.playing = true
	elif not is_moving:
		$WalkSound.playing = false

var zoom_idx = 6
var zoom_level = [0.5 , 0.59, 0.66, 0.73, 0.81, 0.9 , 1.  , 1.1 , 1.21, 1.33, 1.46, 1.61, 1.77, 1.95, 2.14, 2.36, 2.59, 2.85, 3.  ]
func zoom_loop() -> void:
	if Input.is_action_just_pressed("zoom_in"):  zoom_idx = clamp(zoom_idx+1, 0, len(zoom_level)-1)
	if Input.is_action_just_pressed("zoom_out"): zoom_idx = clamp(zoom_idx-1, 0, len(zoom_level)-1)
	camera.zoom = Vector2(zoom_level[zoom_idx], zoom_level[zoom_idx])

var dist_ratio : float
func rumble_loop() -> void:
	if level == null: return
	var rainbow_letter = level.get_node_or_null("RainbowLetter")
	if rainbow_letter != null:
		var dist = position.distance_to(rainbow_letter.position)
		dist_ratio = clamp(1.0-dist/RUMBLE_DISTANCE,0,1)
	else: dist_ratio = lerp(dist_ratio, 0.0, 0.05)
	
	camera.SHAKE_SPEED = clamp(CAM_MAX_SPEED*dist_ratio, 0, CAM_MAX_SPEED)
	camera.SHAKE_STRENGTH = clamp(CAM_MAX_POW*dist_ratio, 0, CAM_MAX_POW)
	AudioController.volume_db = clamp(-40*dist_ratio, -40, -10)


const COLORS = ["Cyan", "Magenta", "Yellow", "Black"]
signal invert(color_name)
func invert_helper(color):
	var color_i = COLORS.find(color)
	set_collision_mask_value(5+color_i, !get_collision_mask_value(5+color_i))
	set_collision_mask_value(13+color_i, !get_collision_mask_value(5+color_i))
	emit_signal("invert", color)
	AudioController.sound_play("InvertingColor")
	
func color_invert_loop():
	if Input.is_action_just_pressed("color_C") and "Cyan" in inventory:
		invert_helper("Cyan")
	if Input.is_action_just_pressed("color_M") and "Magenta" in inventory:
		invert_helper("Magenta")
	if Input.is_action_just_pressed("color_Y") and "Yellow" in inventory:
		invert_helper("Yellow")
	if Input.is_action_just_pressed("color_K") and "Black" in inventory:
		invert_helper("Black")

func _ready():
	sprite.material.set_shader_parameter("center", sprite.get_rect().size/2.0)

@onready var level = get_parent().get_node("level_0")
func _process(_delta):
	for child in get_parent().get_children():
		if "level" in child.name: level = child
	
	rumble_loop()
	color_invert_loop()
	zoom_loop()

func _physics_process(_delta):
	move_loop()
	anim_loop()


func _on_area_2d_body_entered(body):
	print(body)


func _on_death_timer_timeout():
	set_collision_layer_value(2, true)
