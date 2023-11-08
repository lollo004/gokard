extends Node

var GameController
var card


func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")
	card = get_parent().get_parent()


func Effect(team): # When enemy turn starts gain +1 attack
	if card.Team != team and card.Location == "field":
		card.BoostByPos(card.Position, "attack", 1, card.Team) # Boost attack
