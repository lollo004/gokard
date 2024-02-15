extends Node

var GameController # Game controller reference


func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")
	
	_on_Update()


func _on_Update():
	var turn = GameController.turn
	var phase = GameController.phase
	
	if turn == "player" and phase == "Defense":
		get_tree().get_first_node_in_group("Turn").text = "End\nPhase"
	if turn == "player" and phase == "Attack":
		get_tree().get_first_node_in_group("Turn").text = "End\nTurn"
	if turn == "enemy":
		get_tree().get_first_node_in_group("Turn").text = "Opponent\nTurn"
	
	get_tree().get_first_node_in_group("Lymph").text = str(GameController.lymph)
	get_tree().get_first_node_in_group("Stress").text = str(GameController.stress)


func _on_turn_button_pressed():
	if GameController.turn == "player":
		if not GameController.isScreenTaken:
			get_tree().call_group("ClientInstance", "send_pass") # Tell you passed phase to opponent
			
			GameController.TurnButtonPressed()
		else:
			if GameController.phase == "Attack":
				GameController.UserError("Wait animations end")
			if GameController.phase == "Defense":
				GameController.UserError("Choose turn type")
	else:
		GameController.UserError("Wait until your turn starts")

