extends Camera2D

@export var main_camera_state: CameraState
@export var player_camera_state: CameraState

@onready var default_camera_state : CameraState = player_camera_state
@onready var prev_camera_state : CameraState = default_camera_state
@onready var camera_state : CameraState = default_camera_state

#@export var SHAKE_SPEED: float = 30.0
#@export var SHAKE_STRENGTH: float = 60.0

#@onready var rand = RandomNumberGenerator.new()
#@onready var noise = FastNoiseLite.new()

#var noise_i: float = 0.0
#var shake_strength: float = 0.0

var transition_curve : Curve = Curve.new()

func _ready() -> void:
	global_position = default_camera_state.global_position
	Util.entered_cam_state.connect(func(new_camera_state):
		prev_camera_state = camera_state
		camera_state = new_camera_state
		transition_curve = camera_state.transition_curve
		t = 0)
	Util.exited_cam_state.connect(func(new_camera_state):
		main_camera_state.zoom = zoom
		prev_camera_state = main_camera_state
		camera_state = default_camera_state
		transition_curve = camera_state.transition_curve
		t = 0)
	
	#rand.randomize()
	#noise.seed = rand.randi()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("scroll_up"): zoom *= 1.1
	elif Input.is_action_just_pressed("scroll_down"): zoom *= 0.9
	
	#shake_strength = SHAKE_STRENGTH
	#self.offset = get_noise_offset(delta)

# - ordered priority list of cam sttes to prioritize in case multiple are activated.
# - Both zoom level (at different zoom.x and zoom.y levels) AND position x and y lerping, such that they both arrive at the same time.
# - The camera states can be activated on a trigger (broforce inspired) or by areas. so both an activate trigger and a deactivate trigger.
# - Fix zoom so it doesn't scale but rather just makes black bars (for non linked xy)
# - Rumble controls, i.e. Constant rumbling with prameters and customizable t val
# - More instant rumble with custom “timers” and easing options.

var t = 1.0
func _physics_process(delta: float) -> void:
	t = clamp(t+delta, 0.0, 1.0)
	var y = transition_curve.sample(t)
	global_position = lerp(prev_camera_state.global_position, camera_state.global_position, y)
	zoom = lerp(prev_camera_state.zoom, camera_state.zoom, y)

#func get_noise_offset(delta: float) -> Vector2:
	#noise_i += delta * SHAKE_SPEED
	#return Vector2(
		#noise.get_noise_2d(1, noise_i) * shake_strength,
		#noise.get_noise_2d(100, noise_i) * shake_strength
	#)
