extends Node

var GameController
var card


func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")
	card = get_parent().get_parent()


func Effect(team): # When you draw a card gain +1 attack
	if team == card.Team and card.Location == "field":
		card.Attack += 1 # Gain 1 attack
		card.UpdateStats(card) # Update your stats
