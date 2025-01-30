extends StaticBody2D

@export var merchant_type = Lib.MERCHANT_TYPES.BEDOUIN


@onready var vp = get_parent().get_viewport_rect().size
@onready var rest_position = Vector2(vp.x/2, vp.y/4)

@onready var sprite: Sprite2D = $Sprite2D
@onready var carpet: Sprite2D = $carpet
@onready var panel_1: Label = $Panel1
@onready var panel_2: Label = $Panel2
@onready var area_left: Area2D = $carpet/AreaLeft
@onready var area_right: Area2D = $carpet/AreaRight



func _ready() -> void:
	global_position.x = vp.x/2.0
	global_position.y = -128

var is_leaving := false
func _process(delta: float) -> void:
	#global_position = global_position.lerp(rest_position, delta*3.0)
	if !is_leaving:
		if global_position.y < vp.y/4:
			global_position.y += vp.y/4/256
		else:
			carpet.show()
			carpet.scale.y = lerp(carpet.scale.y, 3.0, delta*4.0)
			sprite.material.set_shader_parameter("anim_speed", 0.0)
	else:
		if carpet.scale.y < 0.05:
			carpet.hide()
			global_position.y -= vp.y/4/256
			sprite.material.set_shader_parameter("anim_speed", 15.0)
		else:
			panel_1.hide()
			panel_2.hide()
			carpet.scale.y = lerp(carpet.scale.y, 0.0, delta*6.0)


@onready var sprite_2d: Sprite2D = $carpet/AreaLeft/Sprite2D
@onready var sprite_2d_3: Sprite2D = $carpet/AreaRight/Sprite2D3
func _on_area_left_area_entered(area: Area2D) -> void:
	sprite_2d.material.set_shader_parameter("is_on", true)
	sprite_2d_3.material.set_shader_parameter("is_on", false)
func _on_area_right_area_entered(area: Area2D) -> void:
	sprite_2d.material.set_shader_parameter("is_on", false)
	sprite_2d_3.material.set_shader_parameter("is_on", true)


func _on_merchant_timer_timeout() -> void:
	Lib.merchant_finished.emit()
	is_leaving = true
