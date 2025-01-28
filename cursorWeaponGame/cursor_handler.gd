extends Node2D

#const WEAPON_SWORD = preload("res://weapons/CursorSword.tscn")
#const WEAPON_SPEAR = preload("res://weapons/CursorSpear.tscn")
#@onready var weapon_sword = WEAPON_SWORD.instantiate()
#@onready var weapon_spear = WEAPON_SPEAR.instantiate()

enum WEAPON_TYPE {SWORD, SPEAR, RAPIER}
@onready var weapon_sword: Area2D = %CursorSword
@onready var weapon_spear: Area2D = %CursorSpear

@onready var weapon_dict = {
	WEAPON_TYPE.SWORD: weapon_sword,
	WEAPON_TYPE.SPEAR: weapon_spear,
}

func _ready() -> void:
	weapon_sword.set_process(true)
	weapon_spear.set_process(false)


func disable(weapon_instance) -> void:
	weapon_instance.set_process(false)
	weapon_instance.global_position = Vector2(-100, -100)

func enable(weapon_instance) -> void:
	weapon_instance.set_process(true)
	weapon_instance.global_position = get_global_mouse_position()

var current_weapon := WEAPON_TYPE.SWORD :
	set(new_weapon):
		if new_weapon != current_weapon:
			disable(weapon_dict[current_weapon])
			enable(weapon_dict[new_weapon])
			current_weapon = new_weapon


func _process(_delta: float) -> void:
	if   Input.is_action_just_pressed("1"): current_weapon = WEAPON_TYPE.SWORD
	elif Input.is_action_just_pressed("2"): current_weapon = WEAPON_TYPE.SPEAR
