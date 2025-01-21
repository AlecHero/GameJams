extends CharacterBody2D

@export var base_life := 10
const MOVE_SPEED = 50


var current_life = base_life

func damage(n):
	current_life -= n
	if current_life > 0:
		# knockback
		pass
	else: # die
		queue_free()


var life_ball
func _ready() -> void:
	life_ball = get_parent().get_node("CursorHandler").get_node("%LifeBall")


@export var knockback_recovery = 3.5
var knockback = Vector2.ZERO
func _physics_process(delta: float) -> void:
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	if life_ball != null:
		var direction = global_position.direction_to(life_ball.global_position)
		velocity = direction*MOVE_SPEED
		velocity += knockback
		move_and_slide()


func _on_hit_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("CursorWeapon"):
		damage(area.dmg)
