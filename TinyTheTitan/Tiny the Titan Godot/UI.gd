extends CanvasLayer

@onready var debug_ui = %DebugUI
@onready var debug_container = $DebugUI/DebugContainer
@onready var popup = %ItemMenuButton.get_popup()
@onready var heart_1 = %Heart1
@onready var heart_2 = %Heart2
@onready var heart_3 = %Heart3
@onready var animation_player = $AnimationPlayer
@onready var player = get_parent().get_node("Player")
@onready var star_container = %StarContainer
@onready var main_camera: Camera2D = %MainCamera

const ANIM_HEART0 = 0
const ANIM_HEART1 = 1

var debug_section = preload("res://Prefabs/DebugSection.tscn")
var debug_list = {}
var lookup = {
	0 : "ring",
	1 : "boots",
	2 : "wings",
	3 : "claws",
}
func _ready():
	info_ui.hide()
	info_ui.get_child(0).position.y = -1000
	
	popup.id_pressed.connect(func(id): return player.receive_item(lookup[id]))
	show()
	debug_list = {
		"is_dead": func(): return player.is_dead,
		"is_knockedback": func(): return player.is_knockedback,
		"is_on_floor()": func(): return player.is_on_floor(),
		"was_on_floor": func(): return player.was_on_floor,
		"is_on_ladder": func(): return player.is_on_ladder,
		"was_on_ladder": func(): return player.was_on_ladder,
		"bigmode": func(): return player.bigmode,
		"was_bigmode": func(): return player.was_bigmode,
		"is_flying": func(): return player.is_flying,
		"was_airborne": func(): return player.was_airborne,
		"is_informed": func(): return player.is_informed,
		"is_in_water": func(): return player.is_in_water,
		"is_overlapping": func(): return player.is_overlapping,
		"is_in_ground": func(): return player.is_in_ground,
		"is_stuck": func(): return player.is_stuck,
		"is_on_wall": func(): return player.is_on_wall(),
		"is_on_wall_only": func(): return player.is_on_wall_only(),
		"is_in_spike": func(): return player.is_in_spike,
		"   ": func(): return "",
		"prev_camera_state": func(): return main_camera.prev_camera_state.name,
		"camera_state": func(): return main_camera.camera_state.name,
		"": func(): return "",
		"current_jumps": func(): return player.current_jumps,
		"extra_jumps": func(): return player.extra_jumps,
		"current_life": func(): return player.current_life,
		"position": func(): return round(player.position),
		"velocity": func(): return round(player.velocity),
		"mouse_pos": func(): return snapped(player.get_global_mouse_position(), Vector2(0.1, 0.1)),
		" ": func(): return "",
		"inventory": func(): return player.inventory,
		"current_progress": func(): return player.current_progress,
		"saved_progress": func(): return player.saved_progress,
	}
	
	for property in debug_list:
		var sec = debug_section.instantiate()
		sec.property = property
		sec.state = debug_list[property]
		debug_container.add_child(sec)

func heart_dance():
	animation_player.play("RESET")
	animation_player.play("HeartDance")
func star_dance():
	animation_player.play("RESET")
	animation_player.play("StarDance")

@onready var ring_sprite = %RingSprite
@onready var boots_sprite = %BootsSprite
@onready var wings_sprite = %WingsSprite
@onready var claws_sprite = %ClawsSprite


func _process(_delta):
	info_ui.get_child(0).size = DisplayServer.screen_get_size()
	info_ui.get_child(0).position = Vector2(0,0)
	
	$Control/FPS.text = str(Engine.get_frames_per_second())
	
	info_loop()
	
	heart_1.frame = ANIM_HEART1
	heart_2.frame = ANIM_HEART1
	heart_3.frame = ANIM_HEART1
	
	if player.current_life <= 2: heart_3.frame = ANIM_HEART0
	if player.current_life <= 1: heart_2.frame = ANIM_HEART0
	if player.current_life <= 0: heart_1.frame = ANIM_HEART0
	
	var stars = star_container.get_children()
	for i in range(len(stars)-1, -1, -1):
		stars[i].get_child(0).frame = int(i in player.stars) + 2
	
	ring_sprite.frame = 0 if "ring" in player.inventory else 4
	boots_sprite.frame = 1 if "boots" in player.inventory else 4
	wings_sprite.frame = 2 if "claws" in player.inventory else 4
	claws_sprite.frame = 3 if "wings" in player.inventory else 4
	
	if Input.is_action_just_pressed("DEBUG"):
		debug_ui.visible = !debug_ui.visible

@onready var info_label = %InfoLabel
@onready var info_ui = $InfoUI
@onready var info_timer = $InfoTimer
@onready var info_anim = $InfoAnim

var is_info_shown = false
var timer_done = false
func info_loop():
	info_label.text = player.text_info
	if player.is_informed and not is_info_shown:
		info_anim.play("info_show")
		#await info_anim.animation_finished
		is_info_shown = true
	elif is_info_shown:
		is_info_shown = false
		info_timer.start()
		await info_timer.timeout
		info_anim.play("info_hide")
		#await info_anim.animation_finished


var info_items = {
	"ring": {
		"name":"The Ring of Scaling",
		"subtext":"Harness the power to grow beyond your limits."},
	"boots": {
		"name":"Featherstep, Sole of the Skies",
		"subtext":"Defy gravity and ascend with ease."},
	"wings": {
		"name":"Captive Feather",
		"subtext":"A single feather from a celestial being, imprisoned for ages."},
	"claws": {
		"name":"Titan’s Grip",
		"subtext":"Feel the strength of ancient giants as you scale the tallest trees."},
}
