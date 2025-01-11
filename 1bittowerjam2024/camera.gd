extends Camera2D

@onready var player: CharacterBody2D = $"../Player"
@onready var tower: StaticBody2D = $"../Tower"
@onready var level_handler: Node2D = %LevelHandler

var t := 0.0

func _process(delta: float) -> void:
	if player.is_in_tower_zone or player.is_targeting or level_handler.is_leaving or level_handler.is_entering:
		position = lerp(position, tower.get_node("TowerZone/Marker2D").global_position, 0.05)
		zoom = lerp(zoom, Vector2(1, 1), 0.05)
	else:
		position = lerp(position, player.global_position, 0.05)
		zoom = lerp(zoom, Vector2(3, 3), 0.01)
	
	shake_strength = SHAKE_STRENGTH
	self.offset = get_noise_offset(delta) * t

# The Shaggy Dev:
@export var SHAKE_SPEED: float = 30.0
@export var SHAKE_STRENGTH: float = 60.0

@onready var rand = RandomNumberGenerator.new()
@onready var noise = FastNoiseLite.new()

var noise_i: float = 0.0
var shake_strength: float = 0.0

func get_noise_offset(delta: float) -> Vector2:
	noise_i += delta * SHAKE_SPEED
	return Vector2(
		noise.get_noise_2d(1, noise_i) * shake_strength,
		noise.get_noise_2d(100, noise_i) * shake_strength
	)
