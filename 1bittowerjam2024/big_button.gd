extends Area2D

@onready var big_button: StaticBody2D = $".."
@onready var enemy_handler: Node = $"../../EnemyHandler"
@onready var sprite: Sprite2D = $Sprite2D
@onready var intro_guide: Node2D = %IntroGuide
var is_activated := false
var is_pressed := false
var is_just_released := false
var tower_button_pos = Vector2i(384, 204)
var is_initial := true

func _process(delta: float) -> void:
	if is_activated and Input.is_action_pressed("interact"):
		is_pressed = true
	elif is_activated:
		if is_pressed:
			is_just_released = true
		is_pressed = false
	
	if is_pressed: sprite.frame = 1
	else: sprite.frame = 0
		
	if is_just_released:
		is_just_released = false
		if intro_guide != null:
			intro_guide.queue_free()
		if is_initial:
			is_initial = false
			big_button.global_position = tower_button_pos
			Util.scene_changed.emit(Enemy.BEAST_TYPES.GOBLIN)
		else:
			AudioController.play("next_wave")
			Util.next_wave.emit()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		is_activated = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		is_activated = false
