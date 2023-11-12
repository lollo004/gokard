extends Node

var GameController


func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")


func Effect(team): #Give +5 attack and +2 health to all the dwarfs in your field
	if team == "player":
		for i in GameController.player_field_cards:
			i.BoostByPos(i.Position, "attack", 5, "player") # Gain attack
			i.BoostByPos(i.Position, "health", 2, "player") # Gain attack
			
		get_tree().call_group("ClientInstance", "send_effect_144") # Send to opponent cards to boost


