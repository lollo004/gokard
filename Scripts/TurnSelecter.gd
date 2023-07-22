extends Area2D


func _on_play_pressed():
	if get_tree().get_first_node_in_group("TurnManager").visible:
		GameController.PlayCard()
		get_tree().get_first_node_in_group("TurnManager").visible = false


func _on_draw_pressed():
	if get_tree().get_first_node_in_group("TurnManager").visible:
		GameController.DrawCard()
		get_tree().get_first_node_in_group("TurnManager").visible = false
	


func _on_lymph_pressed():
	if get_tree().get_first_node_in_group("TurnManager").visible:
		GameController.AddLymph()
		get_tree().get_first_node_in_group("TurnManager").visible = false
	


func _on_stress_pressed():
	if get_tree().get_first_node_in_group("TurnManager").visible:
		GameController.AddStress()
		get_tree().get_first_node_in_group("TurnManager").visible = false
	


func _on_hide_pressed():
	if get_tree().get_first_node_in_group("TurnManager").visible:
		get_tree().get_first_node_in_group("TurnManager").visible = false
		get_tree().get_first_node_in_group("ShowButton").visible = true


func _on_show_pressed():
		get_tree().get_first_node_in_group("TurnManager").visible = true
		get_tree().get_first_node_in_group("ShowButton").visible = false
