extends Node2D

@onready var debug_ui = get_node("../UI/DebugUI")
@onready var rumble_particle: GPUParticles2D = $RumbleParticle
@onready var tower_sprite: Sprite2D = %Tower/Sprite2D
@onready var camera: Camera2D = %Camera
@onready var spawn_node: Node2D = $SpawnNode
@onready var player: CharacterBody2D = %Player

## Tilemap Layers
@onready var intro: TileMapLayer = $Intro
@onready var goblin: TileMapLayer = $Goblin
@onready var skeleton: TileMapLayer = $Skeleton
@onready var cyclops: TileMapLayer = $Cyclops
@onready var spirit: TileMapLayer = $Spirit
@onready var desert: TileMapLayer = $Desert
@onready var spider: TileMapLayer = $Spider
@onready var robot: TileMapLayer = $Robot
@onready var devil: TileMapLayer = $Devil
@onready var tilemap_layers = [
	goblin, skeleton, cyclops, spirit,
	desert, spider, robot, devil,
]

#[astar_regular, astar_climb, astar_flying]
var current_layer : TileMapLayer
var spawn_pos = preload("res://Prefabs/spawn_pos.tscn")
var current_type : Enemy.BEAST_TYPES
var new_type : Enemy.BEAST_TYPES

var t := 0.0;
var is_leaving := false
var is_entering := false

func _ready() -> void:
	for layer in tilemap_layers:
		layer.collision_enabled = false
	current_layer = intro
	current_layer.collision_enabled = true
	Util.scene_changed.connect(change_scene)

var astar_regular : Dictionary
var astar_climb : Dictionary
var astar_flying : Dictionary
var all_astar = [astar_regular, astar_climb, astar_flying]
func remake_astar():
	astar_regular = AStarUtil.create_astar(current_layer, AStarUtil.ASTAR_TYPES.REGULAR)
	for node in spawn_node.get_children():
		spawn_node.remove_child(node)
		node.queue_free()
	for spawn in astar_regular["spawns"]:
		var sp = spawn_pos.instantiate()
		sp.global_position = current_layer.map_to_local(spawn)
		spawn_node.add_child(sp)
	astar_climb = AStarUtil.create_astar(current_layer, AStarUtil.ASTAR_TYPES.CLIMB)
	astar_flying = AStarUtil.create_astar(current_layer, AStarUtil.ASTAR_TYPES.FLYING)
	all_astar = [astar_regular, astar_climb, astar_flying]


func change_scene(beast_type : Enemy.BEAST_TYPES):
	is_leaving = true
	rumble_particle.emitting = true
	new_type = beast_type

func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("DEBUG"):
		#remake_astar()
	
	if is_leaving:
		material.set_shader_parameter("progress", t)
		camera.t = 1.0-t
		rumble_particle.emitting = true
		rumble_particle.amount_ratio = 1.0-t
		t += delta * 0.33
		if t >= 1.0:
			is_leaving = false
			rumble_particle.emitting = false
			current_layer.hide() # old layer
			current_layer.collision_enabled = false
			player.position = player.respawn_pos
			current_layer = tilemap_layers[new_type]
			remake_astar()
			Util.scene_actual_change.emit()
			current_layer.show() # new layer
			current_layer.collision_enabled = true
			is_entering = true
			t = 0.0
	elif is_entering:
		material.set_shader_parameter("progress", 1.0-t)
		camera.t = 1.0-t
		rumble_particle.emitting = true
		rumble_particle.amount_ratio = t
		t += delta * 0.33
		if t >= 1.0:
			is_entering = false
			rumble_particle.emitting = false
			t = 0.0
		#material.set_shader_parameter("progress", t)
