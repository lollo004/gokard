extends Label

func _process(delta):
	self.text = "Lymph: " + str(GameController.lymph)
