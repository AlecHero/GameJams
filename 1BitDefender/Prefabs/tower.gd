extends StaticBody2D

@onready var player: CharacterBody2D = %Player
@onready var self_outline: Node2D = $SelfOutline
@onready var key_e: Sprite2D = $KeyE
@onready var shop_ui: PanelContainer = %ShopUI
@onready var health_bar: ProgressBar = $Healthbar/HealthBar

var max_life := 5000.0
var current_life : float = max_life:
	set(new_current_life):
		current_life = clamp(new_current_life, 0, max_life)

func _process(delta: float) -> void:
	if player.is_in_tower_zone:
		self_outline.show()
		key_e.show()
		if Input.is_action_just_pressed("interact"):
			shop_ui.visible = !shop_ui.visible
	else:
		self_outline.hide()
		key_e.hide()
		shop_ui.hide()
	
	health_bar.material.set_shader_parameter("progress", current_life / max_life)

func hit(power : float) -> void:
	current_life = clamp(current_life-power, 0, max_life)

func repair() -> void:
	current_life += max_life * 0.005
