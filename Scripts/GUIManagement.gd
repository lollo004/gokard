extends Node


func _process(delta):
	var turn = GameController.turn
	var phase = GameController.phase
	
	if turn == "player" and phase == "defense":
		get_tree().get_first_node_in_group("Turn").text = "End Phase"
	if turn == "player" and phase == "attack":
		get_tree().get_first_node_in_group("Turn").text = "End Turn"
	if turn == "enemy":
		get_tree().get_first_node_in_group("Turn").text = "Opponent Turn"
	
	get_tree().get_first_node_in_group("Lymph").text = "Lymph: " + str(GameController.lymph)
	
	get_tree().get_first_node_in_group("Stress").text = "Stress: " + str(GameController.stress)


func _on_turn_button_pressed():
	if not GameController.isScreenTaken:
		GameController.TurnButtonPressed()

