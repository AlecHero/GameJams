extends Node2D

#const WEAPON_SWORD = preload("res://weapons/CursorSword.tscn")
#const WEAPON_SPEAR = preload("res://weapons/CursorSpear.tscn")
@onready var cursor: Node2D = %Cursor

const SWORD_STEEL = preload("res://weapons/swords/SteelSword.tscn")
const SWORD_BIG = preload("res://weapons/swords/BigSword.tscn")
const SWORD_GIANT = preload("res://weapons/swords/GiantSword.tscn")
const CLUB = preload("res://weapons/swords/Club.tscn")
const BIG_CLUB = preload("res://weapons/swords/BigClub.tscn")
const STEEL_CLUB = preload("res://weapons/swords/SteelClub.tscn")
const STEEL_HAMMER = preload("res://weapons/swords/SteelHammer.tscn")
const MJOLNIR = preload("res://weapons/swords/Mjolnir.tscn")


enum WEAPON_TYPE {SWORD, SPEAR, RAPIER}



@onready var weapon_sword: Area2D = %CursorSword
@onready var weapon_spear: Area2D = %CursorSpear



@onready var weapon_dict = {
	WEAPON_TYPE.SWORD: weapon_sword,
	WEAPON_TYPE.SPEAR: weapon_spear,
}


func _ready() -> void:
	weapon_sword.cursor = cursor
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


var upgrade_list = [STEEL_HAMMER, MJOLNIR, CLUB, BIG_CLUB, STEEL_CLUB, SWORD_STEEL, SWORD_BIG, SWORD_GIANT]
func _process(_delta: float) -> void:
	if   Input.is_action_just_pressed("1"): current_weapon = WEAPON_TYPE.SWORD
	elif Input.is_action_just_pressed("2"): current_weapon = WEAPON_TYPE.SPEAR
	elif Input.is_action_just_pressed("upgrade"):
		if len(upgrade_list) > 0:
			var upgraded_weapon = upgrade_list.pop_front().instantiate()
			upgraded_weapon.cursor = cursor
			weapon_sword.queue_free()
			weapon_sword = upgraded_weapon
			weapon_dict[WEAPON_TYPE.SWORD] = weapon_sword
			add_child(upgraded_weapon)
