extends CanvasLayer

@onready var debug_ui: Control = $DebugUI
@onready var debug_menu: VBoxContainer = %DebugMenu
@onready var gradient_shader = get_node("../GradientShader")
@onready var enemy_handler = get_node("../EnemyHandler")
@onready var beast_dropdown: OptionButton = %BeastDropdown
@onready var toggle_shader: CheckButton = %ToggleShader
@onready var fps_ui: PanelContainer = $FPSUI
@onready var player: CharacterBody2D = %Player

var debug_section = preload("res://Prefabs/DebugSection.tscn")
var debug_list = {}

func _ready() -> void:
	debug_ui.hide()
	fps_ui.hide()
	
	for beast_type in Enemy.BEAST_TYPES.keys():
		beast_dropdown.add_item(beast_type)
	beast_dropdown.item_selected.connect(func(beast_type): Util.scene_changed.emit(beast_type))
	beast_dropdown.selected = enemy_handler.current_beast_type
	toggle_shader.toggled.connect(func(toggled_on): gradient_shader.visible = toggled_on)
	
	debug_list = {
		"current_beast_type" : func(): return Enemy.BEAST_TYPES.keys()[enemy_handler.current_beast_type],
		"" : func() : return "",
		"current_song" : func() : return AudioController.current_song.name,
		"current_ambiance" : func() : return AudioController.current_ambiance.name,
		"is_ambiance_waiting" : func() : return AudioController.is_ambiance_waiting,
		"currently_selected" : func() : return player.current_selected,
	}
	
	for property in debug_list:
		var section = debug_section.instantiate()
		section.property = property
		section.state = debug_list[property]
		debug_menu.add_child(section)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("DEBUG"):
		debug_ui.visible = !debug_ui.visible
