extends Line2D

@onready var cursor: Node2D = %Cursor
@onready var life_ball: RigidBody2D = %LifeBall
@onready var rope_ball: Sprite2D = $RopeBall
@onready var rope_ball2: Sprite2D = $RopeBall2
@onready var shadow: Line2D = $shadow
@onready var shadow_rope_ball_2: Sprite2D = $shadow/RopeBall2

func _ready() -> void:
	add_point(Vector2.ZERO, 0)
	add_point(Vector2.ZERO, 1)
	shadow.add_point(Vector2.ZERO, 0)
	shadow.add_point(Vector2.ZERO, 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	set_point_position(0, cursor.position)
	set_point_position(1, life_ball.position+Vector2(0,3))
	rope_ball.global_position = cursor.position# + Vector2(0.0, 3.0)
	rope_ball2.global_position = life_ball.position+Vector2(0,3)# + Vector2(0.0, 3.0)

	var offset = Vector2(0, 3*3)
	shadow.set_point_position(0, cursor.position + offset)
	shadow.set_point_position(1, life_ball.position+Vector2(0,3) + offset)
	var ang = (cursor.position + offset).angle_to_point(life_ball.position+Vector2(0,3) + offset)
	shadow_rope_ball_2.global_position = cursor.position + offset# + Vector2(0.0, 3.0)
	shadow_rope_ball_2.rotation = ang
