extends Node

@onready var player: CharacterBody2D = $".."
@onready var items = get_node("../../%Items")
@onready var air_rumble = $AirRumble
@onready var camera: Camera2D = $"../../MainCamera"

var item_dists := []
var rumble_volume := Util.RUMBLE_VOLUME
var rumble_dist := 0

func _process(delta: float) -> void:
	rumble_volume = Util.RUMBLE_VOLUME+10 if player.bigmode else Util.RUMBLE_VOLUME
	
	if player.bigmode: air_rumble.pitch_scale = 1.0
	else: air_rumble.pitch_scale = 2.0
	
	if not player.is_on_floor() and not player.is_on_ladder and player.velocity.y > 600:
		air_rumble.volume_db = lerp(air_rumble.volume_db, -80.+ rumble_volume, 0.1)
	elif player.is_flying:
		air_rumble.pitch_scale = 3.
		air_rumble.volume_db = lerp(air_rumble.volume_db, -80.+rumble_volume*0.8, 0.1)
	else:
		air_rumble.volume_db = lerp(air_rumble.volume_db, -80., 0.02)
	
	
	item_dists = []
	var items_list = items.get_children()
	for item in items_list:
		if item.item_name not in player.inventory:
			item_dists.append(player.global_position.distance_to(item.global_position))
		else: item_dists.append(INF)
	var closest_item_dist = item_dists.min()
	var closest_item = items_list[item_dists.find(closest_item_dist)]
	
	rumble_dist = clamp(closest_item_dist, 0., 900.)
	var rumble_ratio = 1 - rumble_dist/900.
	
	if rumble_dist < 900:
		AudioServer.set_bus_volume_db(1, -30 * rumble_ratio)
	else:
		AudioServer.set_bus_volume_db(1, lerp(AudioServer.get_bus_volume_db(1), 0.0, 0.05))
		rumble_ratio = lerp(rumble_ratio, 0.0, 0.05)
	
	#camera.SHAKE_SPEED    = clamp(Util.CAM_MAX_SPEED * rumble_ratio, 0, Util.CAM_MAX_SPEED)
	#camera.SHAKE_STRENGTH = clamp(Util.CAM_MAX_POWER * rumble_ratio, 0, Util.CAM_MAX_POWER)
