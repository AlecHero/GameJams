extends CharacterBody2D

var rng = RandomNumberGenerator.new()
var g = 9.81

@onready var sprite = $Sprite2D

@export var init_pos := Vector2.ZERO # Vector2(304,576)
@export var SPEED = 75
@export var ANIM_SPEED = 35
@export_subgroup("Jump")
@export var GRAVITY := .4
@export var JUMP_SQUISH = 1.0
@export var JUMP_IMPULSE = 4.0
@export var SQUISH_WEIGHT = 15.0

var sword_swing = preload("res://Prefabs/PlayerSwing.tscn")
var bullet_proj = preload("res://Prefabs/PlayerProjectile.tscn")
var arrow_proj = preload("res://Prefabs/PlayerArrow.tscn")

@onready var tower: StaticBody2D = %Tower
@onready var timer_sword: Timer = $TimerSword
@onready var timer_bow: Timer = $TimerBow
@onready var timer_hammer: Timer = $TimerHammer
@onready var target_outline: Node2D = %TargetOutline
@onready var range_outline: Node2D = %RangeOutline

var gold := 0
var is_placing := false
var current_selected := 0
var sprite_velocity := Vector2.ZERO
var respawn_pos := init_pos
var is_grounded := false
var is_in_tower_zone := false
var was_airborne := false

func _ready():
	Util.gold_dropped.connect(func(x): gold += x)
	respawn_pos = position

func animation_loop(delta) -> void:
	var is_moving = Util.any_input(["up", "down", "left", "right"])
	if is_moving and is_grounded:
		sprite.material.set_shader_parameter("anim_speed", ANIM_SPEED)
	else:
		sprite.material.set_shader_parameter("anim_speed", 0)

	if was_airborne:
		was_airborne = false
		sprite.material.set_shader_parameter("squish_amount", -JUMP_SQUISH)
	
	if is_grounded:
		sprite.frame = Util.ANIMATION_STATES.IDLE
	elif Input.is_action_pressed("left"):
		sprite.frame = Util.ANIMATION_STATES.JUMP_L
	elif Input.is_action_pressed("right"):
		sprite.frame = Util.ANIMATION_STATES.JUMP_R
	elif sprite_velocity.y >= 0:
		sprite.frame = Util.ANIMATION_STATES.FALL
	
	var lerped_squish = lerp(sprite.material.get_shader_parameter("squish_amount"), 0.0, delta * SQUISH_WEIGHT)
	sprite.material.set_shader_parameter("squish_amount", lerped_squish)


func _process(delta):
	animation_loop(delta)
	is_placing = current_selected == 2 or current_selected == 3
	
	if is_placing and !is_targeting:
		target_outline.show()
		range_outline.show()
		var half_side = 16*3
		var mouse_pos = get_global_mouse_position()
		mouse_pos = mouse_pos.clamp(Vector2(global_position.x-half_side, global_position.y-half_side), Vector2(global_position.x+half_side, global_position.y+half_side))
		target_outline.global_position = Util.snap(mouse_pos)
		range_outline.global_position = Util.snap(global_position)
	else:
		target_outline.hide()
		range_outline.hide()
	
	if   Input.is_action_just_pressed("1"): current_selected = 0
	elif Input.is_action_just_pressed("2"): current_selected = 1
	elif Input.is_action_just_pressed("3"): current_selected = 2
	elif Input.is_action_just_pressed("4"): current_selected = 3
	elif Input.is_action_just_pressed("scroll_up"): current_selected = (current_selected - 1) % 4
	elif Input.is_action_just_pressed("scroll_down"): current_selected = (current_selected + 1) % 4

func move_loop(_delta) -> void:
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * SPEED
	move_and_slide()


func jump_loop():
	if is_grounded and Input.is_action_pressed("ui_select"):
		sprite_velocity.y = -JUMP_IMPULSE
		is_grounded = false
	
	is_grounded = ($Sprite2D.position.y == 0)
	if not is_grounded:
		was_airborne = true
		collision_mask = 0b00000000000000000000000000000110
		sprite_velocity.y += GRAVITY
	else:
		collision_mask = 0b00000000000000000000000100000110
	
	$Sprite2D.position = clamp($Sprite2D.position + sprite_velocity, -Vector2.INF, Vector2.ZERO)

func _physics_process(delta):
	if Input.is_action_pressed("left_click") or Input.is_action_just_pressed("left_click"):
		if current_selected == 0 and timer_sword.is_stopped():
			timer_sword.start()
			var swing = sword_swing.instantiate()
			swing.position = global_position
			swing.position.y -= 3 # offset
			swing.damage = 15
			swing.look_at(get_global_mouse_position())
			get_parent().add_child(swing)
		elif current_selected == 1 and timer_bow.is_stopped():
			timer_bow.start()
			var arrow = arrow_proj.instantiate()
			arrow.final_position = get_global_mouse_position()
			arrow.position = global_position
			arrow.position.y -= 3 # offset
			arrow.damage = 7.5
			arrow.look_at(get_global_mouse_position())
			get_parent().add_child(arrow)
		elif current_selected == 3 and timer_hammer.is_stopped():
			timer_hammer.start()
			if (tower.global_position-get_global_mouse_position()).length() < 16:
				tower.repair()
				AudioController.play("repair")
	
	move_loop(delta)
	jump_loop()

var is_in_shop_zone := false
var is_targeting := false
func _on_tower_search_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area.name == "TowerZone": is_in_tower_zone = true
	elif area.name == "ShopZone": is_in_shop_zone = true
	elif "Ballista" in area.name: is_targeting = true
	elif "Fireballer" in area.name: is_targeting = true

func _on_tower_search_area_shape_exited(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area.name == "TowerZone": is_in_tower_zone = false
	elif area.name == "ShopZone": is_in_shop_zone = false
	elif "Ballista" in area.name: is_targeting = false
	elif "Fireballer" in area.name: is_targeting = false
