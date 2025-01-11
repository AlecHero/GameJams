@tool
class_name CameraState
extends Node2D

enum CAMERA_TYPES { NONE, MAIN, PLAYER, STATIC }

@onready var area_activation: Area2D = $AreaActivation
@onready var collision_shape_2d: CollisionShape2D = $AreaActivation/CollisionShape2D

var camera_type : CAMERA_TYPES :
	set(new_camera_type):
		camera_type = new_camera_type
		notify_property_list_changed()
var activation_collision_shape: Shape2D
var transition_curve : Curve
var zoom: Vector2 = Vector2(1.0, 1.0)


func _get_property_list() -> Array:
	var properties: Array = []
	
	properties.append({
		"name": "camera_type",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "None,Main,Player,Static",
	})
	if camera_type != CAMERA_TYPES.NONE:
		if camera_type == CAMERA_TYPES.STATIC:
			properties.append({
				"name": "activation_collision_shape",
				"type": TYPE_OBJECT,
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_RESOURCE_TYPE,
				"hint_string": "Shape2D",
			})
			properties.append({
				"name": "transition_curve",
				"type": TYPE_OBJECT,
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_RESOURCE_TYPE,
				"hint_string": "Curve",
			})
		properties.append({
			"name": "zoom",
			"type": TYPE_VECTOR2,
			"usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_LINK,
		})
	return properties


func _ready() -> void:
	collision_shape_2d.shape = activation_collision_shape


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		var new_shape: Shape2D
		new_shape = activation_collision_shape
		collision_shape_2d.shape = new_shape
		
		if camera_type == CAMERA_TYPES.NONE:
			area_activation.hide()
		elif camera_type == CAMERA_TYPES.MAIN:
			area_activation.hide()
		elif camera_type == CAMERA_TYPES.PLAYER:
			area_activation.hide()
		elif camera_type == CAMERA_TYPES.STATIC:
			area_activation.show()
	
	else:
		if camera_type == CAMERA_TYPES.NONE:
			area_activation.monitoring = false
		elif camera_type == CAMERA_TYPES.MAIN:
			area_activation.monitoring = false
		elif camera_type == CAMERA_TYPES.PLAYER:
			area_activation.monitoring = false
		elif camera_type == CAMERA_TYPES.STATIC:
			area_activation.monitoring = true

func _on_area_activation_body_entered(body: Node2D) -> void:
	Util.entered_cam_state.emit(self)

func _on_area_activation_body_exited(body: Node2D) -> void:
	Util.exited_cam_state.emit(self)
