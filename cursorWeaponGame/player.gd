extends CharacterBody2D

func _physics_process(delta: float) -> void:
	velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * 200.0
	move_and_slide()

var push_force = 50
