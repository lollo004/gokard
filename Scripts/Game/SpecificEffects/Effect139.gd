extends Node

var GameController


func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")


func Effect(team): # +3 health to a dwarf
	if team == "player" and GameController.selected_card_to_target_with_magic.Gene == "Dwarf":
		GameController.selected_card_to_target_with_magic.BoostByPos(GameController.selected_card_to_target_with_magic.Position, "health", 3, GameController.selected_card_to_target_with_magic.Team) # Gain +3 health
		
		get_tree().call_group("ClientInstance", "send_effect_139", GameController.selected_card_to_target_with_magic.Position, GameController.selected_card_to_target_with_magic.Team) # Send to opponent the card to boost

