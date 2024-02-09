extends Node

var GameController
var card


func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")
	card = get_parent().get_parent()


func Effect(attacker, _death, _n): # When he attack he dies
	if card == attacker:
		card.Health -= card.Health # Kill himself
		card.UpdateStats(card) # Tell him to update his stats
