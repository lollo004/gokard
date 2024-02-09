extends Node

var GameController
var card


func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")
	card = get_parent().get_parent()


func Effect(team): # When some other defense card uses the special give +1 attack and +1 health to all your card on the field and reduce by 1 the cost of 1 card in your hand
	if card.Team == team and card.Location == "field":
		if team == "player":
			for i in GameController.player_field_cards:
				i.BoostByPos(i.Position, "attack", 1, "player") # Boost attack
				i.BoostByPos(i.Position, "health", 1, "player") # Boost health
			
		if len(GameController.player_hand) != 0:
			if len(GameController.player_hand) > 1:
				var rnd = Data.RANDOM.randi_range(0, len(GameController.player_hand) - 1)
				GameController.player_hand[rnd].BoostByPos(GameController.player_hand[rnd].Position, "cost", -1, "player") # Reduce cost
			else:
				GameController.player_hand[0].BoostByPos(GameController.player_hand[0].Position, "cost", -1, "player") # Reduce cost
		else:
			for i in GameController.enemy_field_cards:
				i.BoostByPos(i.Position, "attack", 1, "enemy") # Boost attack
				i.BoostByPos(i.Position, "health", 1, "enemy") # Boost health
			
			if len(GameController.enemy_hand) != 1:
				Data.RANDOM.randi_range(0,1) # Sync clients seed
