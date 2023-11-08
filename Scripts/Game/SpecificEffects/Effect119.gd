extends Node

var GameController
var card


func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")
	card = get_parent().get_parent()


func Effect(_team, _pos, who): # When someone plays a dwarf gain +1 attack and +1 health
	if who.Gene == "Dwarf" and who != self:
		card.BoostByPos(card.Position, "attack", 1, card.Team) # Boost attack
		card.BoostByPos(card.Position, "health", 1, card.Team) # Boost health
