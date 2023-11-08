extends Node

var GameController
var card


func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")
	card = get_parent().get_parent()


func Effect(_team, _pos, who): # When someone plays a card he gain +1 attack
	if card.Location == "field" and card != who:
		card.BoostByPos(card.Position, "attack", 1, card.Team) # Boost attack
