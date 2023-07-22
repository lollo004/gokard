extends Sprite2D


func _process(delta):
	if not len(GameController.player_hand) > 0: # Play button
		get_tree().get_first_node_in_group("PlayButton").disabled = true
	
	if not len(GameController.player_deck) > 0: # Draw button
		get_tree().get_first_node_in_group("DrawButton").disabled = true
	
	if not GameController.lymph < GameController.max_lymph: # Lymph button
		get_tree().get_first_node_in_group("LymphButton").disabled = true
	
	if not GameController.stress < GameController.max_stress: # Stress button
		get_tree().get_first_node_in_group("StressButton").disabled = true
