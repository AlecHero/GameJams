extends CanvasLayer

@onready var player: CharacterBody2D = %Player
@onready var shop_ui: PanelContainer = %ShopUI
@onready var player_ui: Control = $PlayerUI
@onready var enemy_handler: Node = $"../EnemyHandler"

@onready var icon_sword: TextureRect = $PlayerUI/MarginContainer/MarginContainer/HBoxContainer/IconSword
@onready var icon_bow: TextureRect = $PlayerUI/MarginContainer/MarginContainer/HBoxContainer/IconBow
@onready var icon_held: TextureRect = $PlayerUI/MarginContainer/MarginContainer/HBoxContainer/IconHeld
@onready var icon_hammer: TextureRect = $PlayerUI/MarginContainer/MarginContainer/HBoxContainer/IconHammer
@onready var wave_timer_text: Label = $WaveTimer/PanelContainer2/WaveTimerText
@onready var gold_label: Label = $PlayerUI/MarginContainer2/MarginContainer/GoldLabel

func _ready() -> void:
	shop_ui.hide()

func _process(delta: float) -> void:
	if player.current_selected == 0:
		icon_sword.material.set_shader_parameter("is_activated", true)
		icon_bow.material.set_shader_parameter("is_activated", false)
		icon_held.material.set_shader_parameter("is_activated", false)
		icon_hammer.material.set_shader_parameter("is_activated", false)
	elif player.current_selected == 1:
		icon_sword.material.set_shader_parameter("is_activated", false)
		icon_bow.material.set_shader_parameter("is_activated", true)
		icon_held.material.set_shader_parameter("is_activated", false)
		icon_hammer.material.set_shader_parameter("is_activated", false)
	elif player.current_selected == 2:
		icon_sword.material.set_shader_parameter("is_activated", false)
		icon_bow.material.set_shader_parameter("is_activated", false)
		icon_held.material.set_shader_parameter("is_activated", true)
		icon_hammer.material.set_shader_parameter("is_activated", false)
	elif player.current_selected == 3:
		icon_sword.material.set_shader_parameter("is_activated", false)
		icon_bow.material.set_shader_parameter("is_activated", false)
		icon_held.material.set_shader_parameter("is_activated", false)
		icon_hammer.material.set_shader_parameter("is_activated", true)
	
	var sword_t = 1.0-player.timer_sword.time_left/player.timer_sword.wait_time
	if sword_t > 0.99: sword_t = 0.0
	icon_sword.material.set_shader_parameter("t", sword_t)
	
	var bow_t = 1.0-player.timer_bow.time_left/player.timer_bow.wait_time
	if bow_t > 0.99: bow_t = 0.0
	icon_bow.material.set_shader_parameter("t", bow_t)
	
	var hammer_t = 1.0-player.timer_hammer.time_left/player.timer_hammer.wait_time
	if hammer_t > 0.99: hammer_t = 0.0
	icon_hammer.material.set_shader_parameter("t", hammer_t)

	var wave_text = "Next Wave : {num}s".format({"num":floor(enemy_handler.wave_timer.time_left)})
	wave_timer_text.text = wave_text
	
	gold_label.text = "Gold : %04d" % floor(player.gold)

func _on_spike_button_pressed() -> void:
	pass # Replace with function body.

func _on_ballista_button_pressed() -> void:
	pass # Replace with function body.
