extends Node

var GameController # Game controller reference


func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")
	
	_on_Update()


func _on_Update():
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
	
	get_tree().get_first_node_in_group("Player_Life").text = str(GameController.player_health)
	get_tree().get_first_node_in_group("Enemy_Life").text = str(GameController.enemy_health)


func _on_turn_button_pressed():
	if not GameController.isScreenTaken:
		GameController.TurnButtonPressed()

