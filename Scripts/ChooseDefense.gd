extends Area2D


func _on_defende_button_pressed():
	get_tree().call_group("Card", "isDefenseOk", GameController.started_defende_card, "defende")
	GameController.DefenseResult(true)
	get_tree().call_group("Deactivable", "Enable", true)
	queue_free()


func _on_cancel_button_pressed():
	get_tree().call_group("Card", "isDefenseOk", GameController.started_defende_card, "")
	GameController.DefenseResult(false)
	get_tree().call_group("Deactivable", "Enable", true)
	queue_free()


func _on_special_button_pressed():
	get_tree().call_group("Card", "isDefenseOk", GameController.started_defende_card, "special")
	GameController.DefenseResult(false)
	get_tree().call_group("Deactivable", "Enable", true)
	queue_free()

