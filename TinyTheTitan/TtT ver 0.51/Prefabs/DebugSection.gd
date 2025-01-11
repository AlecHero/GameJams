extends MarginContainer

@export var property = "property"
@export var state = "state"

func _process(_delta):
	$HSplitContainer/property.text = property
	$HSplitContainer/state.text = str(state.call())
