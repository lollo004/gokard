extends Sprite2D

var GameController # Game controller reference


func _ready(): #Setup first datas
	GameController = get_tree().get_first_node_in_group("GameController")
	
	_on_Update()


func _on_Update():
	if not len(GameController.player_hand) > 0: # Play button (aggiungere anche il controllo sulle carte in tavola)
		get_tree().get_first_node_in_group("PlayButton").disabled = true
	else:
		get_tree().get_first_node_in_group("PlayButton").disabled = false
	
	if not (len(GameController.player_deck) > 0 and len(GameController.player_hand) < 10): # Draw button
		get_tree().get_first_node_in_group("DrawButton").disabled = true
	else:
		get_tree().get_first_node_in_group("DrawButton").disabled = false
	
	if not GameController.lymph < GameController.max_lymph: # Lymph button
		get_tree().get_first_node_in_group("LymphButton").disabled = true
	else:
		get_tree().get_first_node_in_group("LymphButton").disabled = false
	
	if not GameController.stress < GameController.max_stress: # Stress button
		get_tree().get_first_node_in_group("StressButton").disabled = true
	else:
		get_tree().get_first_node_in_group("StressButton").disabled = false

