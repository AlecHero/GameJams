extends CharacterBody2D

var rng = RandomNumberGenerator.new()

@onready var sprite = $Sprite2D
@onready var climb_area = $ClimbArea
@onready var camera = $Camera2D
@onready var ui = get_parent().get_node("UI")

@onready var collision_poly = $CollisionPolygon2D
@onready var hit_poly = $HitArea/CollisionPolygon2D
@onready var climb_poly = $ClimbArea/CollisionPolygon2D
@onready var death_poly = $DeathArea/CollisionPolygon2D

@onready var sound_big2small = $Big2Small
@onready var sound_small2big = $Small2Big
@onready var sound_jump = $Jump
@onready var sound_bigjump = $BigJump
@onready var sound_hit = $Hit
@onready var air_rumble = $AirRumble

var item_lookup = {0:"ring", 1:"boots", 2:"wings", 3:"claws"}

var jump_particle = preload("res://jump_particle.tscn")

# GRAVITY = 2000:
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var current_gravity = gravity

# ANIMATION
const ANIM_IDLE = 0
const ANIM_FALL = 1
const ANIM_KNOCKED_R = 2
const ANIM_KNOCKED_L = 3
const ANIM_JUMP_R = 4
const ANIM_JUMP_L = 5
const ANIM_CLIMB_R = 6
const ANIM_CLIMB_L = 7
const ANIM_FLYING_R = 8
const ANIM_FLYING_L = 9
const ANIM_FLYING_IDLE = 10
const ANIM_DEAD = 11

const ANIM_SPEED = 40.0
const BIG_ANIM_SPEED = ANIM_SPEED/2
var anim_climb_dir = true
var dir = 1

const SPEED = 330.0
const SMALL_SCALE = Vector2(1.0,1.0)
const JUMP_VELOCITY = -640.0
const JUMP_SQUISH = -1.0
const JUMP_IMPACT = 1.0
const CLIMB_SPEED = -70.0
var jump_squish = JUMP_SQUISH
var jump_velocity = JUMP_VELOCITY
var extra_jumps = 1
var current_jumps = extra_jumps

const BIG_SPEED = SPEED*0.6
const BIG_SCALE = SMALL_SCALE*4
const BIG_JUMP_VELOCITY = JUMP_VELOCITY*1.5
const BIG_JUMP_SQUISH = JUMP_SQUISH*0.75
const BIG_JUMP_IMPACT = JUMP_IMPACT*0.75

const FALL_SPEED = 1200
const FLYING_FALL_SPEED = 150
var fall_speed = FALL_SPEED

var INIT_POS = Vector2(304,576)
var respawn_point = INIT_POS

# COLLISION
const SMALL_POLY = [Vector2(-2, -2), Vector2(2, -2), Vector2(2, 3), Vector2(-2, 3)]
const BIG_POLY = [Vector2(-8, -18), Vector2(8, -18), Vector2(8, 3), Vector2(-8, 3)]
var current_scale = SMALL_SCALE
var current_poly = SMALL_POLY

# RUMBLE
const CAM_MAX_SPEED = 300
const CAM_MAX_POW = 10
const RUMBLE_VOLUME = 80
var rumble_volume = RUMBLE_VOLUME
var rumble_dist = 0

# PROGRESS
const MAX_LIFE = 3
var current_life = MAX_LIFE

# ring of embiggening, super-light boots, bear claws, wings
var inventory = []
var stars = []

var saved_progress = {"inventory":[], "stars":0}
var current_progress = {"inventory":[], "stars":0}

signal received_health
signal received_star

# STATES
var bigmode = false
var is_dead = false
var is_on_ladder = false
var is_dying = false
var is_knockedback = false
var is_hittable = true
var is_flying = false
var is_in_water = false
var is_informed = false
var was_airborne = false
var was_on_ladder = false
var was_bigmode = false


func _ready():
	received_health.connect(ui.heart_dance)
	received_star.connect(ui.star_dance)
	respawn_point = position #Vector2(304, 576)
	inventory_loop()
	save_progress()


func reset_progress() -> void:
	current_progress = saved_progress.duplicate()
	inventory = current_progress["inventory"]
	stars = current_progress["stars"]
	
	current_life = MAX_LIFE
	is_dead = false
	velocity = Vector2.ZERO
	position = respawn_point

func save_progress() -> void:
	saved_progress = current_progress.duplicate()


func attacked(damage) -> void:
	sound_hit.play()
	if is_hittable:
		$ITimer.start()
		is_hittable = false
		emit_signal("hit")
		$AnimationPlayer.play("iframes")
		current_life = max(0, current_life - damage)
		is_dead = current_life == 0
		is_dying = is_dead
		
	if not is_dead:
		is_knockedback = true
		velocity = -velocity*0.8
		velocity.x += rng.randf_range(-300, 300)

func full_life():
	current_life = MAX_LIFE
	emit_signal("received_health")

func receive_star(star):
	print("oi")
	stars.append(star)
	emit_signal("received_star")

func receive_item(item):
	inventory.append(item)

func scale_poly(col_poly, to, weight):
	var points = col_poly.get_polygon()
	for i in range(len(points)):
		points[i] = lerp(points[i], current_poly[i], weight)
	return points

func update_checkpoint(pos):
	respawn_point = pos
	full_life()
	save_progress()

func inventory_loop() -> void:
	current_progress = {
		"inventory":inventory.duplicate(),
		"stars":stars.duplicate(),
	}
	climb_area.set_collision_mask_value(4, ("claws" in inventory))
	bigmode = Input.is_action_pressed("special") and ("ring" in inventory) and not is_dead


@onready var items = %Items
var item_dists = []

func rumble_loop() -> void:
	item_dists = []
	var items_list = items.get_children()
	for item in items_list:
		if item.item_name not in inventory:
			item_dists.append(global_position.distance_to(item.global_position))
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
	
	camera.SHAKE_SPEED = clamp(CAM_MAX_SPEED * rumble_ratio, 0, CAM_MAX_SPEED)
	camera.SHAKE_STRENGTH = clamp(CAM_MAX_POW * rumble_ratio, 0, CAM_MAX_POW)

func animation_loop(delta) -> void:
	var anim_speed = BIG_ANIM_SPEED if bigmode else ANIM_SPEED
	# SPRITE FRAME HANDLING
	if is_on_ladder:
		was_on_ladder = true
		sprite.frame = ANIM_CLIMB_L if anim_climb_dir else ANIM_CLIMB_R
	elif is_flying and Input.is_action_pressed("left"):
		sprite.frame = ANIM_FLYING_L
	elif is_flying and Input.is_action_pressed("right"):
		sprite.frame = ANIM_FLYING_R
	elif is_flying:
		sprite.frame = ANIM_FLYING_IDLE
	elif not is_on_floor() and Input.is_action_pressed("left"):
		sprite.frame = ANIM_JUMP_L
	elif not is_on_floor() and Input.is_action_pressed("right"):
		sprite.frame = ANIM_JUMP_R
	elif not is_on_floor() and velocity.y > 0 and not is_on_ladder:
		sprite.frame = ANIM_FALL
	elif is_on_floor():
		sprite.frame = ANIM_IDLE

	if is_dead:
		sprite.frame = ANIM_DEAD
	if Input.is_action_pressed("right") and not is_dead: dir = 1
	elif Input.is_action_pressed("left") and not is_dead: dir = 0
	
	extra_jumps = 1 + int("boots" in inventory)
	
	if (not is_on_ladder and was_on_ladder): # remove additional jump after ladders
		was_on_ladder = false
		current_jumps = extra_jumps - 1
	
	# WALKING ANIM
	var is_moving = (Input.is_action_pressed("right") or Input.is_action_pressed("left")) and not is_dead
	if is_moving and is_on_floor():
		sprite.material.set_shader_parameter("anim_speed", anim_speed)
	else:
		sprite.material.set_shader_parameter("anim_speed", 0)

	if is_knockedback:
		sprite.frame = ANIM_KNOCKED_L if dir==1 else ANIM_KNOCKED_R

	# JUMP SQUISH
	if not is_on_floor():
		was_airborne = true
	elif was_airborne:
		was_airborne = false
		sprite.material.set_shader_parameter("squish_amount", BIG_JUMP_IMPACT)
	
	var lerped_squish = lerp(sprite.material.get_shader_parameter("squish_amount"), 0.0, delta*(3 if bigmode else 8))
	sprite.material.set_shader_parameter("squish_amount", lerped_squish)


func audio_loop():
	if bigmode: was_bigmode = true
	if not bigmode and was_bigmode:
		sound_small2big.playing = false
		sound_big2small.playing = true
		was_bigmode = false
	if Input.is_action_just_pressed("special") and ("ring" in inventory):
		sound_small2big.playing = true
	if is_dying:
		#play sound
		is_dying = false


const WATER_JUMP_VELOCITY = JUMP_VELOCITY*10

func _process(delta):
	fall_speed = FALL_SPEED if not is_flying else FLYING_FALL_SPEED
	current_poly = BIG_POLY if bigmode else SMALL_POLY
	current_scale = BIG_SCALE if bigmode else SMALL_SCALE
	jump_squish = BIG_JUMP_SQUISH if bigmode else JUMP_SQUISH
	if bigmode:
		jump_velocity = BIG_JUMP_VELOCITY
	elif is_in_water:
		jump_velocity = WATER_JUMP_VELOCITY
	else:
		jump_velocity = JUMP_VELOCITY
	rumble_volume = RUMBLE_VOLUME+10 if bigmode else RUMBLE_VOLUME
	is_flying = Input.is_action_pressed("up") and ("wings" in inventory) and velocity.y > 0 and not bigmode
	
	if is_flying:
		current_gravity = gravity/2
	elif is_in_water and not bigmode:
		current_gravity = -gravity
	else:
		current_gravity = gravity
	
	if is_on_floor() or is_on_ladder: current_jumps = extra_jumps
	if is_on_floor(): is_knockedback = false
	
	if bigmode: air_rumble.pitch_scale = 1.0
	else: air_rumble.pitch_scale = 2.0
	
	if not is_on_floor() and not is_on_ladder and velocity.y > 600:
		air_rumble.volume_db = lerp(air_rumble.volume_db, -80.+ rumble_volume, 0.1)
	elif is_flying:
		air_rumble.pitch_scale = 3.
		air_rumble.volume_db = lerp(air_rumble.volume_db, -80.+rumble_volume*0.8, 0.1)
	else:
		air_rumble.volume_db = lerp(air_rumble.volume_db, -80., 0.02)
	
	rumble_loop()
	inventory_loop()
	audio_loop()
	animation_loop(delta)


func _physics_process(delta):
	# BIGMODE SCALE:
	sprite.scale = sprite.scale.lerp(current_scale, 0.4) # < include delta
	
	collision_poly.set_polygon(scale_poly(collision_poly, current_poly, 0.4))
	hit_poly.set_polygon(scale_poly(hit_poly, current_poly, 0.4))
	climb_poly.set_polygon(scale_poly(climb_poly, current_poly, 0.4))
	death_poly.set_polygon(scale_poly(death_poly, current_poly, 0.4))
	
	if (not is_on_floor() and not is_on_ladder) or is_on_ladder:
		velocity.y += current_gravity * delta
		if is_on_ladder and not Input.is_action_pressed("down"):
			velocity.y = clamp(velocity.y, -INF, 0)
	
	if Input.is_action_just_pressed("up") and ((is_on_floor() or is_on_ladder or (is_in_water and not bigmode)) or (current_jumps > 0 and not bigmode)) and not is_dead:
		velocity.y = jump_velocity
		if bigmode: sound_bigjump.play()
		else: sound_jump.play()
		sprite.material.set_shader_parameter("squish_amount", jump_squish)
	
		if current_jumps == 1 and extra_jumps == 2:
			var particle = jump_particle.instantiate()
			particle.direction = velocity
			add_child(particle)
		current_jumps -= 1
	
	
	if Input.is_action_just_pressed("down") or Input.is_action_just_pressed("up") or Input.is_action_just_pressed("right") or Input.is_action_just_pressed("left"):
		anim_climb_dir = !anim_climb_dir
	
	if Input.is_action_pressed("down") and is_on_floor() and not is_dead:
		current_jumps -= 1
		position.y += 1
	
	var speed = BIG_SPEED if bigmode else SPEED
	var direction = Input.get_axis("left", "right")
	if is_knockedback: pass
	elif direction and not is_dead:
		velocity.x = direction * speed
	else: velocity.x = move_toward(velocity.x, 0, speed)
	
	if is_in_water and not bigmode:
		velocity.y = clamp(velocity.y, -200, INF)
	else:
		velocity.y = clamp(velocity.y, -INF, fall_speed)
	
	if is_in_water and not bigmode:
		velocity.y -= 1
	move_and_slide()
	


func _on_death_area_body_entered(_body): attacked(3)
func _on_hit_area_body_entered(_body): attacked(1)

func _on_climb_area_body_entered(_body): is_on_ladder = not is_knockedback
func _on_climb_area_body_exited(_body): is_on_ladder = false

func _on_i_timer_timeout(): is_hittable = true

func _on_water_area_body_entered(_body): is_in_water = true
func _on_water_area_body_exited(_body): is_in_water = false

var text_info = ""
func _on_info_area_area_entered(area):
	if "Info" in area.name:
		is_informed = true
		text_info = area.text
func _on_info_area_area_exited(area):
	if "Info" in area.name:
		is_informed = false
		text_info = area.text
