extends MarginContainer

@export var property = "property"
@export var state = "state"

func _process(_delta):
	$HSplitContainer/property.text = property
	var called = state.call()
	if called is float:
		called = snapped(called, 0.1)
	elif called is Vector2:
		called = called.snappedf(0.1)
	$HSplitContainer/state.text = str(called)
	
