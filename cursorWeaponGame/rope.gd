extends Line2D

@onready var cursor: CharacterBody2D = %Cursor
@onready var life_ball: RigidBody2D = %LifeBall
@onready var rope_ball: Sprite2D = $RopeBall
@onready var rope_ball2: Sprite2D = $RopeBall2

func _ready() -> void:
	add_point(Vector2.ZERO, 0)
	add_point(Vector2.ZERO, 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	set_point_position(0, cursor.position)
	set_point_position(1, life_ball.position+Vector2(0,3))
	rope_ball.global_position = cursor.position# + Vector2(0.0, 3.0)
	rope_ball2.global_position = life_ball.position+Vector2(0,3)# + Vector2(0.0, 3.0)
