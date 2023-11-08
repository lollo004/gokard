extends Node

var GameController
var card


func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")
	card = get_parent().get_parent()


func Effect(who, _death, n): # If he perform the first attack he gain +1 health
	if n == 0 and who == card: # he attacked has first
		card.BoostByPos(card.Position, "health", 1, card.Team) # Boost health
