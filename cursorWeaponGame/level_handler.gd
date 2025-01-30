extends Node2D

const MERCHANT_BEDOUIN = preload("res://merchants/MerchantBedouin.tscn")
const MERCHANT_CAVER = preload("res://merchants/MerchantCaver.tscn")
const MERCHANT_GYPSY = 0
const MERCHANT_FROG = 0
const MERCHANT_MONSTER = 0
const MERCHANT_WITCH = 0

var merchant_list = [MERCHANT_BEDOUIN, MERCHANT_CAVER]
#var merchant_list = [MERCHANT_BEDOUIN, MERCHANT_GYPSY, MERCHANT_FROG, MERCHANT_MONSTER, MERCHANT_WITCH]
@onready var vp = get_parent().get_viewport_rect().size


func _ready() -> void:
	Lib.wave_cleared.connect(wave_cleared)
	Lib.merchant_finished.connect(merchant_finished)

var current_wave := 0

func merchant_finished():
	Lib.next_wave.emit(current_wave)


func wave_cleared():
	current_wave += 1
	#var rand_idx = Lib.rng.randi() % len(merchant_list)
	var rand_idx = 0
	var Merchant = merchant_list.pop_at(rand_idx).instantiate()
	add_child(Merchant)
