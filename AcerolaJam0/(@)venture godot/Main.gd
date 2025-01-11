extends Node2D

@onready var halftone_mat = $Shaders/Halftone/ColorRect.material
@onready var ui_animation_player = $UI/AnimationPlayer
@onready var player = get_node_or_null("World/Player")

@export var current_level := 0

@onready var Levels = [
	preload("res://Levels/level_0.tscn"),
	preload("res://Levels/level_1.tscn"),
	preload("res://Levels/level_2.tscn"),
]
func set_level(level) -> void:
	current_level = level
	# Changing level
	for child in get_node("World").get_children():
		if "Player" not in child.name: child.queue_free()
	var scene = Levels[level]
	var lvl_instance = scene.instantiate()
	get_node("World").add_child(lvl_instance)
	# Resetting:
	player.set_life(2)
	player.set_pos(lvl_instance.get_node("Spawnpoint").position)
func get_level() -> int:
	return current_level


func _ready():
	set_level(current_level)
	var vp = get_viewport().get_visible_rect().size
	halftone_mat.set_shader_parameter("aspect_ratio", vp.x / vp.y)
	$UI/CMYK.position = Vector2(896, -128)
	$UI/Health.position = Vector2(0, -128)


func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"): get_tree().quit()
	
	if player != null:
		halftone_mat.set_shader_parameter("pattern_offset", clamp(.1*player.dist_ratio, 0.005, 0.1))
