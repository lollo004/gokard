extends Node

var GameController


func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")


func Effect(_team): # Increment stress by 1 for one phase
	if GameController.stress + GameController.over_stress < GameController.max_stress:
		GameController.over_stress += 1
		GameController.stress += 1
		
		get_tree().call_group("GUI_Manager", "_on_Update")

