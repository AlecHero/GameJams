extends Area2D

#@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var init_position = position
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var dist = (final_position-init_position).length()
@export var speed = 500
@export var damage = 2
var projectile_name = "PlayerArrow"

enum ARROW_TYPES { ARROW, BALLISTA_BOLT }
var arrow_type := ARROW_TYPES.ARROW

const TRAJ_HEIGHT = 80

var final_position = Vector2.ZERO
var projectile_height = 0.0
var flight_time_factor = 1.0
var t = 0.0
var pierce

func _ready() -> void:
	if arrow_type == ARROW_TYPES.ARROW:
		collision_shape_2d.shape.radius = 8
		collision_shape_2d.position = Vector2(8,0)
		sprite.scale = Vector2(1,1)
		sprite.frame = 0
		flight_time_factor = 1.0
		pierce = 2
	elif arrow_type == ARROW_TYPES.BALLISTA_BOLT:
		collision_shape_2d.shape.radius = 12
		collision_shape_2d.position = Vector2(16,0)
		sprite.scale = Vector2(2,1)
		sprite.frame = 1
		flight_time_factor = 2.0
		pierce = 8
	
	collision_shape_2d.disabled = true
	sprite.visible = false

var death_progress := 0.0

func _process(delta: float) -> void:
	var r = clamp(-projectile_height/15, 1.0, 3)
	if arrow_type == ARROW_TYPES.ARROW:
		sprite.scale = Vector2(r,r)
	elif arrow_type == ARROW_TYPES.BALLISTA_BOLT:
		sprite.scale = Vector2(2*r,r)
	
	if is_dead:
		death_progress += delta
		sprite.modulate.a = 1.0-death_progress
		collision_shape_2d.disabled = true
		if death_progress >= 1.0:
			queue_free()

func _physics_process(_delta: float) -> void:
	if t > 0.85: collision_shape_2d.disabled = false
	if (t > 0.95 and arrow_type==ARROW_TYPES.BALLISTA_BOLT): queue_destroy()
	if (t > 0.98 and arrow_type==ARROW_TYPES.ARROW): queue_destroy()
	if not is_dead:
		var progress_position = init_position + ((final_position - init_position) * t)
		projectile_height = -(.5-abs(t-.5)) * (.5+abs(t-.5)) * clamp(TRAJ_HEIGHT * (dist/150), 80, 200)
		var projectile_position = Vector2(
			progress_position.x,
			progress_position.y + projectile_height
		)
		look_at(projectile_position)
		position = projectile_position
		var flight_delta = clamp(0.02 / (dist/150), 0.005, 0.03)
		t += flight_delta * flight_time_factor
		if t > 0.06: sprite.visible = true

var is_dead := false
func queue_destroy():
	if not is_dead:
		is_dead = true
		if arrow_type == ARROW_TYPES.ARROW:
			AudioController.play("hit_arrow")
		elif arrow_type == ARROW_TYPES.BALLISTA_BOLT:
			AudioController.play("hit_ballista")

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemies") and pierce > 0:
		pierce -= 1
		area.hit(damage, projectile_name)
		queue_destroy()
