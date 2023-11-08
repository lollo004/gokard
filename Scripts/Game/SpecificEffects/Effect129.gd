extends Node

var GameController
var card


func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")
	card = get_parent().get_parent()


func Effect(team, _pos, who): # When you play a dwarf gives it +1 health
	if team == card.Team and card.Location == "field" and who != card:
		who.BoostByPos(who.Position, "health", 1, who.Team) # Boost health
