extends Node

var GameController


func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")


func Effect(team): # Wake up all the dwarfs in your field
	if team == "player":
		for i in GameController.player_field_cards:
			i.turnBlockedOnPlay = 0
			
			i.shadow.show()
			i.shadow.process_mode = Node.PROCESS_MODE_INHERIT

