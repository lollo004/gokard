extends Node

var GameController


func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")


func Effect(Team, _Position): # Reveal one random card from enemy hand
	if Team == "enemy":
		if len(GameController.player_hand) != 0:
			if len(GameController.player_hand) > 1:
				get_tree().call_group("ClientInstance", "send_effect_114", Data.RANDOM.randi_range(0, len(GameController.player_hand) - 1)) # Send card to your opponent
			else:
				get_tree().call_group("ClientInstance", "send_effect_114", 0) # Send card to your opponent
	else:
		if len(GameController.enemy_hand) != 1:
			Data.RANDOM.randi_range(0,1) # Sync clients seed
