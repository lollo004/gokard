extends Node

var GameController


func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")


func Effect(_team): # +3 health to a dwarf
	if GameController.selected_card_to_attack.Gene == "Dwarf":
		GameController.selected_card_to_attack.BoostByPos(GameController.selected_card_to_attack.Position, "health", 3, GameController.selected_card_to_attack.Team) # Gain +3 health
		
		get_tree().call_group("ClientInstance", "send_effect_139", GameController.selected_card_to_attack.Position, GameController.selected_card_to_attack.Team) # Send to opponent the card to boost

