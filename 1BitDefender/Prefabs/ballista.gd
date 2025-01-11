extends Area2D

@onready var self_outline: ColorRect = $SelfOutline
@onready var range_outline: Node2D = $RangeOutline
@onready var target_outline: Node2D = $TargetOutline
@onready var target_line: Line2D = $TargetLine
@onready var sprite: Sprite2D = $Sprite2D
@onready var timer_arrow: Timer = $TimerArrow

var arrow_proj = preload("res://Prefabs/PlayerArrow.tscn")

var is_activated := false
var is_targeting := false
var is_set := false
var target_coords := Vector2.ZERO
var target_coords_prev := Vector2.ZERO

enum BALLISTA_ANIM {
	UP, DOWN, RIGHT, LEFT, UP_LEFT, UP_RIGHT, DOWN_LEFT, DOWN_RIGHT
}

func _ready() -> void:
	self_outline.hide()
	range_outline.hide()
	target_outline.hide()
	target_line.hide()

func update_targeting():
	var target_angle = (target_coords - global_position).normalized().angle()
	target_outline.global_position = target_coords
	
	target_line.set_point_position(1, target_coords-global_position)
	target_line.material.set_shader_parameter("angle", (target_coords-global_position).angle())
	
	if target_angle >= -PI/8 and target_angle < PI/8:
		sprite.frame = BALLISTA_ANIM.RIGHT # Right
	elif target_angle >= PI/8 and target_angle < 3*PI/8:
		sprite.frame = BALLISTA_ANIM.DOWN_RIGHT # Up-Right
	elif target_angle >= 3*PI/8 and target_angle < 5*PI/8:
		sprite.frame = BALLISTA_ANIM.DOWN # Up
	elif target_angle >= 5*PI/8 and target_angle < 7*PI/8:
		sprite.frame = BALLISTA_ANIM.DOWN_LEFT # Up-Left
	elif target_angle >= -3*PI/8 and target_angle < -PI/8:
		sprite.frame = BALLISTA_ANIM.UP_RIGHT # Down-Right
	elif target_angle >= -5*PI/8 and target_angle < -3*PI/8:
		sprite.frame = BALLISTA_ANIM.UP # Down
	elif target_angle >= -7*PI/8 and target_angle < -5*PI/8:
		sprite.frame = BALLISTA_ANIM.UP_LEFT # Down-Left
	else:
		sprite.frame = BALLISTA_ANIM.LEFT # Left

var has_just_shot_arrow := false
var t := 0.0

func _process(delta: float) -> void:
	if is_targeting:
		if Input.is_action_just_pressed("left_click") or Input.is_action_just_pressed("interact"):
			is_set = true
			target_coords_prev = target_coords
		
		if not is_set:
			target_coords = get_global_mouse_position()
			var to_target = (target_coords-global_position)
			if to_target.length() > range_outline.scale.x*8.0:
				var dir = to_target.normalized()
				target_coords = (global_position + dir * range_outline.scale.x * 8.0)
			target_coords = Util.snap(target_coords)
			update_targeting()
	else:
		if is_activated:
			range_outline.show()
			target_outline.show()
			target_line.show()
			if Input.is_action_just_pressed("interact"):
				is_targeting = true
				is_set = false
	
	
	# IF TARGET HAS BEEN SET: SHOOT ->
	if (target_coords != Vector2.ZERO) and timer_arrow.is_stopped():
		timer_arrow.start()
		spawn_arrow()
		has_just_shot_arrow = true
		sprite.material.set_shader_parameter("amplitude", randf_range(12,6))
	
	if has_just_shot_arrow:
		has_just_shot_arrow = false
		t = 0.0
	if t <= 1.5:
		sprite.material.set_shader_parameter("t", t)
		t += 2.0*delta
	

func spawn_arrow():
	var arrow = arrow_proj.instantiate()
	arrow.arrow_type = arrow.ARROW_TYPES.BALLISTA_BOLT
	arrow.damage = 35
	arrow.final_position = target_coords
	arrow.position = global_position
	arrow.position.y -= 3 # offset
	get_parent().add_child(arrow)


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		self_outline.show()
		is_activated = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		self_outline.hide()
		range_outline.hide()
		target_outline.hide()
		target_line.hide()
		is_activated = false
		is_targeting = false
		if not is_set:
			target_coords = target_coords_prev
			update_targeting()
