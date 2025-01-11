extends Area2D

@export_multiline var text = ""

func _on_area_entered(area: Area2D) -> void:
	#$InfoPopup.InfoPopup(null, null)
	pass

func _on_area_exited(area: Area2D) -> void:
	#$InfoPopup.HideInfoPopup()
	pass
