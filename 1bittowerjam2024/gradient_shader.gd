extends CanvasLayer

@export_subgroup("Goblin")
@export var goblin_light : Color = Color("#7ee948")
@export var goblin_dark : Color = Color("#070700")

@export_subgroup("Skeleton")
@export var skeleton_light : Color = Color("#fbedd6")
@export var skeleton_dark : Color = Color("#1a0101")

@export_subgroup("Cyclops")
@export var cyclops_light : Color = Color("#afba50")
@export var cyclops_dark : Color = Color("#091600")

@export_subgroup("Spirit")
@export var spirit_light : Color = Color("#6bc8ff")
@export var spirit_dark : Color = Color("#020016")

@export_subgroup("Desert")
@export var desert_light : Color = Color("#dcc068")
@export var desert_dark : Color = Color("#1e0202")

#@export_subgroup("Viking")
#@export var viking_light : Color = Color("#ababd8")
#@export var viking_dark : Color = Color("#1c0023")

@export_subgroup("Spider")
@export var spider_light : Color = Color("#ff7373")
@export var spider_dark : Color = Color("#111101")

@export_subgroup("Robot")
@export var robot_light : Color = Color("#ffea4b")
@export var robot_dark : Color = Color("#110a00")

@export_subgroup("Devil")
@export var devil_light : Color = Color("#ff0000")
@export var devil_dark : Color = Color("#000000")

@export_subgroup("Summon")
@export var summon_light : Color = Color("#d463ff")
@export var summon_dark : Color = Color("#03151e")

var beast_gradients = [
	[goblin_light, goblin_dark], [skeleton_light, skeleton_dark], [cyclops_light, cyclops_dark],
	[spirit_light, spirit_dark], [desert_light, desert_dark],
	#[viking_light, viking_dark],
	[spider_light, spider_dark], [robot_light, robot_dark], [devil_light, devil_dark],
	[summon_light, summon_dark],
]

@onready var enemy_handler: Node = $"../EnemyHandler"
@onready var shader = $ColorRect.material
var gradient := [Color.WHITE,Color.BLACK]

func _ready() -> void:
	Util.scene_changed.connect(func(new_type): gradient = beast_gradients[new_type])

func _process(_delta: float) -> void:
	var shader_primary = shader.get_shader_parameter("primary")
	var shader_secondary = shader.get_shader_parameter("secondary")
	var lerped_primary = lerp(shader_primary, gradient[0], Util.COLOR_TRANSITION_WEIGHT)
	var lerped_secondary = lerp(shader_secondary, gradient[1], Util.COLOR_TRANSITION_WEIGHT)
	shader.set_shader_parameter("primary", lerped_primary)
	shader.set_shader_parameter("secondary", lerped_secondary)
