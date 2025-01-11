extends Node2D

@onready var gradient_shader: CanvasLayer = $GradientShader
@onready var fps: Label = $DEBUG_UI/FPSUI/FPS

func _ready() -> void:
	gradient_shader.show()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	fps.text = str(Engine.get_frames_per_second())
