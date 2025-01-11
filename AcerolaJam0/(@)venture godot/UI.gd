extends CanvasLayer

@onready var health = $Health
@onready var CMYK = $CMYK
@onready var point_label = $Points/PointLabel
@onready var animation_player = $AnimationPlayer
@onready var player = get_parent().get_node("World/Player")

const COLORS = ["Cyan", "Magenta", "Yellow", "Black"]

var is_ui_CMYK_active := false
var is_ui_Hearts_active := false
var is_ui_Points_active := false

func point_block(points):
	if points != 0 and not is_ui_Points_active:
		is_ui_Points_active = true
		animation_player.play("lerp_Points")
	point_label.text = str(points)

var CMYK_bool = [true,true,true,true]
func cmyk_block(color):
	var color_i = COLORS.find(color)
	CMYK_bool[color_i] = !CMYK_bool[color_i]
	var ui_color = get_node("CMYK/"+color)
	ui_color.modulate = Color(1,1,1,(1 if CMYK_bool[color_i] else .4))


func hp_block(hp):
	health.get_node("Sprite2D").frame = hp


func cmyk_loop():
	if "Cyan" in player.inventory and not is_ui_CMYK_active:
		is_ui_CMYK_active = true
		animation_player.play("lerp_CMYK")
	if "Cyan" in player.inventory: $CMYK/Cyan.show()
	if "Magenta" in player.inventory: $CMYK/Magenta.show()
	if "Yellow" in player.inventory: $CMYK/Yellow.show()
	if "Black" in player.inventory: $CMYK/Black.show()


func health_loop():
	if "HeartFruit" in player.inventory and not is_ui_Hearts_active:
		is_ui_Hearts_active = true
		animation_player.play("lerp_Hearts")
	health.get_node("Sprite2D").frame = player.life-1



func _ready():
	player.update_ui_points.connect(point_block)
	player.update_ui_hp.connect(hp_block)
	player.invert.connect(cmyk_block)


func _process(_delta):
	health_loop()
	cmyk_loop()
