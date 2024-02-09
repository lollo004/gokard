extends Node

var GameController
var card


func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")
	card = get_parent().get_parent()


func Effect(who): # When an ally dwarf dies give one of your card +3 attack and +1 health
	if card.Team == who.Team and who.Gene == "Dwarf" and card.Location == "field":
		if card.Team == "player":
			var rnd = Data.RANDOM.randi_range(0, len(GameController.player_field_cards) - 1)
			
			GameController.player_field_cards[rnd].BoostByPos(GameController.player_field_cards[rnd].Position, "attack", 3, "player") # Boost attack
			GameController.player_field_cards[rnd].BoostByPos(GameController.player_field_cards[rnd].Position, "health", 1, "player") # Boost health
			
			#get_tree().call_group("ClientInstance", "send_effect_133", GameController.player_field_cards[rnd].Position) # Send to opponent the card to boost
		if card.Team == "enemy":
			var rnd = Data.RANDOM.randi_range(0, len(GameController.enemy_field_cards) - 1)
			
			GameController.enemy_field_cards[rnd].BoostByPos(GameController.enemy_field_cards[rnd].Position, "attack", 3, "player") # Boost attack
			GameController.enemy_field_cards[rnd].BoostByPos(GameController.enemy_field_cards[rnd].Position, "health", 1, "player") # Boost health
			
			#get_tree().call_group("ClientInstance", "send_effect_133", GameController.player_field_cards[rnd].Position) # Send to opponent the card to boost
