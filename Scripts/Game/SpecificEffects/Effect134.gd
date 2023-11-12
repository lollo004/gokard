extends Node

var GameController
var card

 
func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")
	card = get_parent().get_parent()


func Effect(who): # When someone of them dies then eat the leftovers and gain +1 attack and +8 weight
	if card.Team == who.Team and who.id == card.id and who != card and card.Location == "field":
		if who.Team == "player":
			card.BoostByPos(card.Position, "attack", 1, "player") # Boost attack
			card.BoostByPos(card.Position, "weight", 8, "player") # Boost weight
		else:
			card.BoostByPos(card.Position, "attack", 1, "enemy") # Boost attack
			card.BoostByPos(card.Position, "weight", 8, "enemy") # Boost weight
