extends Button

func _process(delta):
	var turn = GameController.turn
	var phase = GameController.phase
	
	if turn == "player" and phase == "defense":
		self.text = "End Phase"
	if turn == "player" and phase == "attack":
		self.text = "End Turn"
	if turn == "enemy":
		self.text = "Opponent Turn"


func _on_pressed():
	GameController.TurnButtonPressed()
