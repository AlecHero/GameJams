extends CharacterBody2D

var rng = RandomNumberGenerator.new()

@onready var sprite = $Sprite2D
@onready var climb_area = $ClimbArea
@onready var camera = $Camera2D
@onready var ui = get_parent().get_node("UI")

@onready var reg_poly = $Area2D/CollisionPolygon2D
@onready var collision_poly = $CollisionPolygon2D
@onready var hit_poly = $HitArea/CollisionPolygon2D
@onready var climb_poly = $ClimbArea/CollisionPolygon2D
@onready var death_poly = $DeathArea/CollisionPolygon2D
@onready var water_poly = $WaterArea/CollisionPolygon2D

@onready var sound_big2small = $Big2Small
@onready var sound_small2big = $Small2Big
@onready var sound_jump = $Jump
@onready var sound_bigjump = $BigJump
@onready var sound_hit = $Hit

var item_lookup = {0:"ring", 1:"boots", 2:"wings", 3:"claws"}

var jump_particle = preload("res://jump_particle.tscn")

# GRAVITY = 2000:
var current_gravity = Util.GRAVITY

# ANIMATION
var anim_dir := true
var dir := 1

var jump_squish := Util.JUMP_SQUISH
var jump_velocity := Util.JUMP_VELOCITY
var extra_jumps := 1
var current_jumps := extra_jumps

var fall_speed := Util.FALL_SPEED

@export var bigmode_lerp_weight := 0.4
@export var init_pos := Vector2(304,576)
var respawn_point := init_pos

# COLLISION
var current_scale := Util.SMALL_SCALE
var current_poly := Util.SMALL_POLY

# PROGRESS
var current_life := Util.MAX_LIFE

# ring of embiggening, super-light boots, bear claws, wings
var inventory := []
var stars := []

var saved_progress = {"inventory":[], "stars":0}
var current_progress = {"inventory":[], "stars":0}

signal received_health
signal received_star

# STATES
var bigmode := false
var is_dead := false
var is_on_ladder := false
var is_dying := false
var is_knockedback := false
var is_hittable := true
var is_flying := false
var is_in_water := false
var is_informed := false
var is_stuck := false
var was_airborne := false
var was_on_ladder := false
var was_bigmode := false
var was_on_floor := false
var is_overlapping := false
var is_poly_overlapping := false
var is_in_ground := false
var is_in_spike := false

var bigmode_cd := false

@export_flags("Ring", "Boots", "Wings", "Gloves") var start_inventory = 0

var pp = PhysicsPointQueryParameters2D.new()

func _ready():
	$AnimationPlayer.play("RESET")
	var anim_dir_timer = Util.quick_timer(0.2, func(): do_anim_dir = true, false)
	add_child(anim_dir_timer)
	
	pp.collision_mask = 0b00000000_00000000_00000000_00000010
	
	received_health.connect(ui.heart_dance)
	received_star.connect(ui.star_dance)
	
	if start_inventory / 8 >= 1:
		inventory.append("claws")
		start_inventory -= 8
	if start_inventory / 4 >= 1:
		inventory.append("wings")
		start_inventory -= 4
	if start_inventory / 2 >= 1:
		inventory.append("boots")
		start_inventory -= 2
	if start_inventory == 1:
		inventory.append("ring")
		start_inventory -= 1
	
	respawn_point = position #Vector2(304, 576)
	inventory_loop()
	save_progress()

func reset_progress() -> void:
	current_progress = saved_progress.duplicate()
	inventory = current_progress["inventory"]
	stars = current_progress["stars"]
	
	current_life = Util.MAX_LIFE
	$AnimationPlayer.play("RESET")
	is_dead = false
	is_hittable = true
	is_knockedback = false
	velocity = Vector2.ZERO
	position = respawn_point

func save_progress() -> void:
	saved_progress = current_progress.duplicate()

func knockback() -> void:
	is_knockedback = true
	if abs(velocity.y) < 50:
		velocity.y += Util.JUMP_VELOCITY*0.8
	elif spike_cd:
		velocity = -velocity*0.8
	velocity.x += rng.randf_range(-300, 300)

func hit(damage) -> void:
	if not is_dead:
		sound_hit.play()
		
		if is_hittable: # if can be hit, take damage
			$ITimer.start()
			is_hittable = false
			emit_signal("hit")
			$AnimationPlayer.play("iframes")
			current_life = max(0, current_life - damage)
			is_dead = current_life == 0
			is_dying = is_dead
		
		if not is_dead: # if not dead, shuffle around
			knockback()

func full_life():
	current_life = Util.MAX_LIFE
	emit_signal("received_health")

func receive_star(star):
	stars.append(star)
	emit_signal("received_star")

func receive_item(item):
	inventory.append(item)

func scale_poly(from_points, to_points, weight):
	var points = from_points
	var new_points = points.duplicate()
	#is_poly_overlapping = false
	for i in range(len(points)):
		var lerped_point = lerp(new_points[i], to_points[i], weight)
		pp.position = lerped_point + global_position
		if len(get_world_2d().direct_space_state.intersect_point(pp, 1)) > 0 and bigmode:
			new_points = points
			#is_poly_overlapping = true
			break
		new_points[i] = lerped_point
	return new_points

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
	bigmode = Input.is_action_pressed("special") and ("ring" in inventory) and not is_dead and not bigmode_cd and not is_knockedback


func animation_loop(delta) -> void:
	var anim_speed = Util.BIG_ANIM_SPEED if bigmode else Util.ANIM_SPEED
	var squish_amount = (3 if bigmode else 8)
	
	if (Input.is_action_pressed("down") or 
		Input.is_action_pressed("up") or 
		Input.is_action_pressed("jump") or 
		Input.is_action_pressed("right") or 
		Input.is_action_pressed("left")
	) and do_anim_dir:
		do_anim_dir = false
		anim_dir = !anim_dir
	
	if Input.is_action_pressed("right") and not is_dead and not is_knockedback: dir = 1
	elif Input.is_action_pressed("left") and not is_dead and not is_knockedback: dir = 0
	
	# SPRITE FRAME HANDLING
	if is_dead:
		sprite.frame = Util.ANIMATION_STATES.DEAD
	elif is_stuck:
		if anim_dir:
			sprite.frame = Util.ANIMATION_STATES.STUCK_L
		else:
			sprite.frame = Util.ANIMATION_STATES.STUCK_R
	elif is_knockedback:
		if dir:
			sprite.frame = Util.ANIMATION_STATES.KNOCKED_L
		else:
			sprite.frame = Util.ANIMATION_STATES.KNOCKED_R
	elif is_on_ladder:
		was_on_ladder = true
		if anim_dir:
			sprite.frame = Util.ANIMATION_STATES.CLIMB_L
		else:
			sprite.frame = Util.ANIMATION_STATES.CLIMB_R
	elif is_flying:
		if Input.is_action_pressed("left"):
			sprite.frame = Util.ANIMATION_STATES.FLYING_L
		elif Input.is_action_pressed("right"):
			sprite.frame = Util.ANIMATION_STATES.FLYING_R
		else:
			sprite.frame = Util.ANIMATION_STATES.FLYING_IDLE
	elif not is_on_floor():
		if Input.is_action_pressed("left"):
			sprite.frame = Util.ANIMATION_STATES.JUMP_L
		elif Input.is_action_pressed("right"):
			sprite.frame = Util.ANIMATION_STATES.JUMP_R
		elif not is_on_floor() and velocity.y > 0 and not is_on_ladder:
			sprite.frame = Util.ANIMATION_STATES.FALL
		else:
			sprite.frame = Util.ANIMATION_STATES.IDLE
	else:
		sprite.frame = Util.ANIMATION_STATES.IDLE
	
	# WALKING ANIM
	var is_moving = (Input.is_action_pressed("right") or Input.is_action_pressed("left")) and not is_dead
	if is_moving and is_on_floor():
		sprite.material.set_shader_parameter("anim_speed", anim_speed)
	else:
		sprite.material.set_shader_parameter("anim_speed", 0)

	# JUMP SQUISH
	if not is_on_floor():
		was_airborne = true
	elif was_airborne:
		was_airborne = false
		sprite.material.set_shader_parameter("squish_amount", Util.BIG_JUMP_IMPACT)
	
	var lerped_squish = lerp(sprite.material.get_shader_parameter("squish_amount"), 0.0, delta * squish_amount)
	sprite.material.set_shader_parameter("squish_amount", lerped_squish)


func audio_loop():
	if bigmode: was_bigmode = true
	if not bigmode and was_bigmode:
		sound_small2big.playing = false
		sound_big2small.playing = true
		was_bigmode = false
	if Input.is_action_just_pressed("special") and ("ring" in inventory) and bigmode:
		sound_small2big.playing = true
	if is_dying:
		#play sound
		is_dying = false

func _process(delta):
	sprite.scale = sprite.scale.lerp(Util.SMALL_SCALE*bigmode_factor, 0.4) # < include delta
	
	fall_speed = Util.FALL_SPEED if not is_flying else Util.FLYING_FALL_SPEED
	if bigmode and not is_in_ground:
		current_poly = Util.BIG_POLY
	else:
		current_poly = Util.SMALL_POLY
	
	current_scale = Util.BIG_SCALE if bigmode else Util.SMALL_SCALE
	jump_squish = Util.BIG_JUMP_SQUISH if bigmode else Util.JUMP_SQUISH
	
	is_flying = Input.is_action_pressed("jump") and ("wings" in inventory) and velocity.y > 0 and not bigmode
	
	if is_on_floor():
		is_knockedback = false
		was_on_floor = true
	
	if bigmode: 	  jump_velocity = Util.BIG_JUMP_VELOCITY
	elif is_in_water: jump_velocity = Util.WATER_JUMP_VELOCITY
	else: 			  jump_velocity = Util.JUMP_VELOCITY
	
	if is_flying: 					  current_gravity =  Util.GRAVITY/2
	elif is_in_water and not bigmode: current_gravity = -Util.GRAVITY
	else: 							  current_gravity =  Util.GRAVITY
	
	inventory_loop()
	audio_loop()
	animation_loop(delta)

#var remove_jump := false
func jump_loop() -> void:
	extra_jumps = 1 + int("boots" in inventory)
	
	if (not is_on_ladder and was_on_ladder): # % jump after leaving ladders
		was_on_ladder = false
		current_jumps = extra_jumps - 1
	elif (not is_on_floor() and was_on_floor): # % jump after leaving a ledge
		was_on_floor = false
		current_jumps = extra_jumps - 1
	elif Input.is_action_pressed("down") and is_on_floor() and not is_dead: # % jump after getting down from a platform
		position.y += 1
		current_jumps = extra_jumps - 1
	
	var has_extra_jump = (current_jumps > 0 and not bigmode)
	var can_swim = (is_in_water and not bigmode)
	if Input.is_action_just_pressed("jump") and not is_dead and (is_on_floor() or is_on_ladder or has_extra_jump or can_swim or is_stuck):
		if is_stuck: # special stuck jump
			current_jumps = extra_jumps
			bigmode = false
			bigmode_cd = true
			var bigmode_timer : Timer = Util.quick_timer(0.3, func(): bigmode_cd = false)
			add_child(bigmode_timer)
		
		velocity.y = jump_velocity
		current_jumps -= 1
		
		if bigmode: sound_bigjump.play()
		else: sound_jump.play()
		sprite.material.set_shader_parameter("squish_amount", jump_squish)
	
		if current_jumps == 0 and extra_jumps == 2:
			var particle = jump_particle.instantiate()
			particle.direction = velocity
			add_child(particle)
	
	if is_on_floor() or is_on_ladder: current_jumps = extra_jumps

var move_cd := false
var do_anim_dir := false
func ladder_loop() -> void:
	if is_on_ladder and not is_dead and not is_knockedback:
		if Input.is_action_pressed("down"):
			velocity.y = clamp(velocity.y, -INF, Util.CLIMB_SPEED)
		elif Input.is_action_pressed("up"):
			velocity.y = -Util.CLIMB_SPEED*0.7
		else:
			velocity.y = clamp(velocity.y, -INF, 0)
		
		velocity.x = clamp(velocity.x, -Util.SPEED*0.7, Util.SPEED*0.7)

func water_loop() -> void:
	if is_in_water and not bigmode:
		velocity.y = clamp(velocity.y, -200, INF)
	else:
		velocity.y = clamp(velocity.y, -INF, fall_speed)
	
	if is_in_water and not bigmode:
		velocity.y -= 1


func move_loop(delta) -> void:
	var speed = Util.BIG_SPEED if bigmode else Util.SPEED
	var direction = Input.get_axis("left", "right")
	if not is_knockedback:
		if direction and not is_dead:
			velocity.x = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
	
	if not is_on_floor():
		velocity.y += current_gravity * delta

func stuck_loop() -> void:
	is_overlapping = $Area2D.has_overlapping_bodies()
	pp.position = global_position
	is_in_ground = len(get_world_2d().direct_space_state.intersect_point(pp, 1)) > 0
	is_stuck = is_overlapping and get_real_velocity().y == 0 and not is_in_ground and not is_on_floor() and not is_knockedback and not is_dead
	
	if is_stuck and not Input.is_action_pressed("jump"):
		velocity = Vector2.ZERO

var bigmode_factor := 1.0
var spike_cd := true

func _physics_process(delta):
	# BIGMODE SCALING:
	var scaled_poly = scale_poly(reg_poly.get_polygon(), current_poly, bigmode_lerp_weight)
	bigmode_factor = scaled_poly[0][0] / Util.SMALL_POLY[0][0]
	reg_poly.set_polygon(scaled_poly)
	hit_poly.set_polygon(scaled_poly)
	climb_poly.set_polygon(scaled_poly)
	death_poly.set_polygon(scaled_poly)
	water_poly.set_polygon(scaled_poly)
	collision_poly.set_polygon(scaled_poly)
	
	if spike_cd:
		is_in_spike = $HitArea.has_overlapping_bodies()
		if is_in_spike:
			spike_cd = false
			var spike_timer = Util.quick_timer(0.1, func(): spike_cd = true)
			add_child(spike_timer)
			hit(1)
	
	move_loop(delta)
	ladder_loop()
	water_loop()
	stuck_loop()
	jump_loop()
	
	move_and_slide()

func _on_death_area_body_entered(_body): hit(3)
func _on_hit_area_body_entered(_body): hit(1)

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
