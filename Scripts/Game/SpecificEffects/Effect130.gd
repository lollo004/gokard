extends Node

var GameController
var card

var card_counter_on_attack = 0


func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")
	card = get_parent().get_parent()


func Effect(team, _pos, _who): # If 4 or more dwarfs are present on the attack field, then gain +2 health and +2 attack
	card_counter_on_attack = 0
	if team == "player":
		for i in GameController.player_field_cards:
			if int(i.Position) % 2 != 0: # cards are on attack position
				card_counter_on_attack += 1
		if card_counter_on_attack >= 4:
			card.BoostByPos(card.Position, "health", 2, card.Team) # Boost health
			card.BoostByPos(card.Position, "attack", 2, card.Team) # Boost attack
	else:
		for i in GameController.enemy_field_cards:
			if int(i.Position) % 2 != 0: # cards are on attack position
				card_counter_on_attack += 1
		if card_counter_on_attack >= 4:
			card.BoostByPos(card.Position, "health", 2, card.Team) # Boost health
			card.BoostByPos(card.Position, "attack", 2, card.Team) # Boost attack
