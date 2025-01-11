extends KinematicBody2D

signal overheat(heat_num, cooldown_bool)
signal game_over

const SPEED = 20
const MAX_SPEED = 1000
const BULLET_SPEED = 5000
const COOLDOWN = 1
const HEAT_GAIN = 1.2

export(Curve) var heat_loss

var velocity = Vector2()
var mouse_pos = Vector2()
var Sparks = preload("res://Sparks.tscn")
var Bullet = preload("res://Bullet.tscn")
var cooldown = 0
var n = 0
var sound1 = true

const LIFE_MAX = 3
var current_life := LIFE_MAX
var is_dead := false
var is_shooting := true
var heat = 0.0
var cooling_down = false

onready var sprite = $Hull
#onready var sprite_fire = $Hull/Fire
onready var particle_fire = $Hull/Thruster
onready var animation_player = $AnimationPlayer
onready var guns = [$Hull/Gun1, $Hull/Gun2]

func _ready():
	$CollisionPolygon2D4.disabled = false
	$Hull.visible = true
	$Explosion.visible = false
	heat = 0.0
	cooling_down = false
	current_life = LIFE_MAX
	show()

func hit(damage := 1, hit_from := Vector2()):
	make_sparks(hit_from, position)
	current_life -= damage
	if current_life <= 0:
		$AnimationExplosion.play("Explosion")
		MusicController.music_action("fade_out")
		is_dead = true
#		velocity = Vector2.ZERO
		emit_signal("game_over")
		return
	$AnimationExplosion.play("Hit")

func _process(_delta):
	AnimationLoop()
	if Input.is_action_pressed("Shoot") and !cooling_down:
		$Hull/Gun1/Particles2D.emitting = true
		$Hull/Gun2/Particles2D2.emitting = true
	else:
		$Hull/Gun1/Particles2D.emitting = false
		$Hull/Gun2/Particles2D2.emitting = false
	
	if Input.is_action_just_pressed("ui_accept"):
		make_sparks(get_global_mouse_position(), position)

func _physics_process(delta):
	if heat > 100.0:
		cooling_down = true
	if heat < 20.0:
		cooling_down = false
	MovementLoop()
	WeaponLoop(delta)

var num := 0
func WeaponLoop(delta):
	if Input.is_action_pressed("Shoot") and cooldown <= 0 and mouse_pos.normalized() != Vector2.ZERO and !is_dead and !cooling_down:
		is_shooting = true
		cooldown = COOLDOWN * delta
		
		var current_gun = guns[num%2]
		num += 1
		var bullet = Bullet.instance()
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = current_gun.global_position
		bullet.velocity += mouse_pos.normalized() * BULLET_SPEED
		bullet.rotate(sprite.rotation)
		heat += HEAT_GAIN
		[$Shoot, $Shoot2][num%2].play()
	
	elif Input.is_action_just_pressed("Shoot") and cooling_down:
		$Click.play()
	else:
		is_shooting = false
	
	if cooling_down and heat > 0:
		heat -= 25 * delta
	elif heat > 0:
		heat -= heat_loss.interpolate(heat / 100) * delta
	
	if cooldown > 0:
		cooldown -= delta
	emit_signal("overheat", heat, cooling_down)

func make_sparks(pos1, pos2):
	var sparks = Sparks.instance()
	var sparks2 = Sparks.instance()
	get_parent().add_child(sparks)
	get_parent().add_child(sparks2)
	
	sparks.position = position
	sparks.velocity = velocity
	sparks.set_emitting("RoundSpark")
	
	sparks2.position = position
	sparks2.velocity = velocity
	sparks2.set_emitting("HitSpark", pos2 - pos1)

func MovementLoop():
	mouse_pos = get_local_mouse_position()
	if is_dead:
		velocity *= 0.95
	elif Input.is_action_pressed("Thrust") and !is_dead:
		velocity += mouse_pos.normalized() * SPEED
	
	move_and_slide(velocity, Vector2.UP)
	velocity = velocity.clamped(MAX_SPEED)

func AnimationLoop():
	sprite.look_at(get_global_mouse_position())
	particle_fire.emitting = false
	if is_dead:
		pass
	elif Input.is_action_pressed("Thrust") and Input.is_action_pressed("Shoot") and !cooling_down or (cooling_down and Input.is_action_pressed("Thrust")):
		particle_fire.emitting = true
		animation_player.play("Thrust&Shoot")
	elif Input.is_action_pressed("Thrust"):
		particle_fire.emitting = true
		animation_player.play("Thrust")
	elif Input.is_action_pressed("Shoot") or cooling_down:
		animation_player.play("Shoot")
	else:
		animation_player.play("Idle")

func _on_Area2D_body_entered(body):
	if "BoundarySide" in body.get_name():
		velocity = velocity.reflect(Vector2.UP)
		velocity *= 0.75
	elif "BoundaryTop" in body.get_name():
		velocity = velocity.reflect(Vector2.LEFT)
		velocity *= 0.75
