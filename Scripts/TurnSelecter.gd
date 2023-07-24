extends Area2D


func _on_play_pressed():
	if get_tree().get_first_node_in_group("TurnManager").visible:
		get_tree().get_first_node_in_group("TurnManager").visible = false
		get_tree().call_group("Deactivable", "Enable", true)
		GameController.PlayCard()


func _on_draw_pressed():
	if get_tree().get_first_node_in_group("TurnManager").visible:
		get_tree().get_first_node_in_group("TurnManager").visible = false
		get_tree().call_group("Deactivable", "Enable", true)
		GameController.DrawCard()
	


func _on_lymph_pressed():
	if get_tree().get_first_node_in_group("TurnManager").visible:
		get_tree().get_first_node_in_group("TurnManager").visible = false
		get_tree().call_group("Deactivable", "Enable", true)
		GameController.AddLymph()
	


func _on_stress_pressed():
	if get_tree().get_first_node_in_group("TurnManager").visible:
		get_tree().get_first_node_in_group("TurnManager").visible = false
		get_tree().call_group("Deactivable", "Enable", true)
		GameController.AddStress()
	


func _on_hide_pressed():
	if get_tree().get_first_node_in_group("TurnManager").visible:
		get_tree().get_first_node_in_group("TurnManager").visible = false
		get_tree().get_first_node_in_group("ShowButton").visible = true


func _on_show_pressed():
		get_tree().get_first_node_in_group("TurnManager").visible = true
		get_tree().get_first_node_in_group("ShowButton").visible = false
