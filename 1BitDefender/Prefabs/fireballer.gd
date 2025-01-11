extends Area2D

@onready var self_outline: ColorRect = $SelfOutline
@onready var target_outline: Node2D = $TargetOutline
@onready var target_line: Line2D = $TargetLine
@onready var sprite: Sprite2D = $Sprite2D
@onready var timer_fireball: Timer = $TimerFireball
@onready var player: CharacterBody2D = %Player


var fireball_proj = preload("res://Prefabs/fireball.tscn")
var is_activated := false
var is_targeting := false
var is_set := false
var target_coords := Vector2.ZERO
var target_coords_prev := Vector2.ZERO

func _ready() -> void:
	self_outline.hide()
	target_outline.hide()
	target_line.hide()

var has_just_shot_arrow := false
var t := 0.0

func update_targeting():
	target_outline.global_position = target_coords
	target_line.set_point_position(1, target_coords-global_position)
	target_line.material.set_shader_parameter("angle", (target_coords-global_position).angle())

func _process(delta: float) -> void:
	if is_targeting:
		if Input.is_action_just_pressed("left_click") or Input.is_action_just_pressed("interact"):
			is_set = true
			target_coords_prev = target_coords
		
		if not is_set:
			target_coords = Util.snap(get_global_mouse_position())
			update_targeting()
	else:
		if is_activated:
			target_outline.show()
			target_line.show()
			if Input.is_action_just_pressed("interact"):
				is_targeting = true
				is_set = false
	
	
	# IF TARGET HAS BEEN SET: SHOOT ->
	if (target_coords != Vector2.ZERO) and timer_fireball.is_stopped():
		timer_fireball.start()
		spawn_arrow()
		has_just_shot_arrow = true
		sprite.material.set_shader_parameter("amplitude", randf_range(12,6))
	
	if has_just_shot_arrow:
		has_just_shot_arrow = false
		t = 0.0
	if t <= 1.5:
		sprite.material.set_shader_parameter("t", t)
		t += 2.0*delta
	
	#print(is_hovered, Input.is_action_just_pressed("right_click"), player.current_selected == 3)
	if is_hovered and Input.is_action_just_pressed("right_click") and player.current_selected == 3:
		print("oi")

var is_hovered = false
func spawn_arrow():
	var fireball = fireball_proj.instantiate()
	fireball.damage = 15
	fireball.position = global_position
	fireball.position.y -= 15 # offset
	fireball.look_at(target_coords)
	get_parent().add_child(fireball)


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		self_outline.show()
		is_activated = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		self_outline.hide()
		target_outline.hide()
		target_line.hide()
		is_activated = false
		is_targeting = false
		if not is_set:
			target_coords = target_coords_prev
			update_targeting()


func _on_mouse_entered() -> void:
	is_hovered = true

func _on_mouse_exited() -> void:
	is_hovered = false
