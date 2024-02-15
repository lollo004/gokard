extends Area2D

var GameController # Game controller reference


func _ready(): #Setup first datas
	GameController = get_tree().get_first_node_in_group("GameController")


func _on_play_pressed():
	if get_tree().get_first_node_in_group("TurnManager").visible:
		get_tree().get_first_node_in_group("TurnManager").visible = false
		get_tree().call_group("Deactivable", "Enable", true)
		GameController.PlayCard()
		get_tree().call_group("GUI_Manager", "_on_Update")


func _on_draw_pressed():
	if get_tree().get_first_node_in_group("TurnManager").visible:
		get_tree().get_first_node_in_group("TurnManager").visible = false
		get_tree().call_group("Deactivable", "Enable", true)
		GameController.DrawCard()
		get_tree().call_group("GUI_Manager", "_on_Update")


func _on_lymph_pressed():
	if get_tree().get_first_node_in_group("TurnManager").visible:
		get_tree().get_first_node_in_group("TurnManager").visible = false
		get_tree().call_group("Deactivable", "Enable", true)
		GameController.AddLymph()
		get_tree().call_group("GUI_Manager", "_on_Update")


func _on_stress_pressed():
	if get_tree().get_first_node_in_group("TurnManager").visible:
		get_tree().get_first_node_in_group("TurnManager").visible = false
		get_tree().call_group("Deactivable", "Enable", true)
		GameController.AddStress()
		get_tree().call_group("GUI_Manager", "_on_Update")


func _on_hide_pressed():
	if get_tree().get_first_node_in_group("TurnManager").visible:
		get_tree().get_first_node_in_group("TurnManager").visible = false
		get_tree().get_first_node_in_group("ShowButton").visible = true


func _on_show_pressed():
		get_tree().get_first_node_in_group("TurnManager").visible = true
		get_tree().get_first_node_in_group("ShowButton").visible = false


func _on_info_pressed():
	get_tree().get_first_node_in_group("Infos").visible = not get_tree().get_first_node_in_group("Infos").visible

