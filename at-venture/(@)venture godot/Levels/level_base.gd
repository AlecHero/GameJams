extends Node2D
class_name BaseLevel

@onready var GridC = $Tilemap/GridC
@onready var GridC_inv = $Tilemap/GridC_inv
@onready var GridM = $Tilemap/GridM
@onready var GridM_inv = $Tilemap/GridM_inv
@onready var GridY = $Tilemap/GridY
@onready var GridY_inv = $Tilemap/GridY_inv
@onready var GridK = $Tilemap/GridK

@onready var player = get_parent().get_node("Player")

func _ready():
	player.invert.connect(invert_colors)
	player.player_death.connect(reset)

var CMYK = [[true,true,true], [false,false,false]]
func reset():
	CMYK = [[true,true,true], [false,false,false]]

func invert_colors(color):
	match color:
		"Cyan":
			CMYK[0][0] = !CMYK[0][0]; CMYK[1][0] = !CMYK[1][0]
			GridC.modulate     = Color(1,1,1,(1 if CMYK[0][0] else 0.4))
			GridC_inv.modulate = Color(1,1,1,(1 if CMYK[1][0] else 0.4))
		"Magenta":
			CMYK[0][1] = !CMYK[0][1]; CMYK[1][1] = CMYK[0][1]
			GridM.modulate     = Color(1,1,1,(1 if CMYK[0][1] else 0.4))
			GridM_inv.modulate = Color(1,1,1,(1 if CMYK[1][1] else 0.4))
		"Yellow":
			CMYK[0][2] = !CMYK[0][2]; CMYK[1][2] = CMYK[0][2]
			GridY.modulate     = Color(1,1,1,(1 if CMYK[0][2] else 0.4))
			GridY_inv.modulate = Color(1,1,1,(1 if CMYK[1][2] else 0.4))
