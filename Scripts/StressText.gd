extends Label

func _process(delta):
	self.text = "Stress: " + str(GameController.stress)
