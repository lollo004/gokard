extends Node

var GameController


func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")


func UsePlayerEffect(pos): # The dwarf that invoke the special gain +2/+1
	for i in GameController.player_field_cards:
		if i.Position == pos and i.Gene == "Dwarf":
			i.BoostByPos(i.Position, "attack", 2, "player") # Boost attack
			i.BoostByPos(i.Position, "health", 1, "player") # Boost health


func UseEnemyEffect(pos): # The dwarf that invoke the special gain +2/+1
	for i in GameController.enemy_field_cards:
		if i.Position == pos and i.Gene == "Dwarf":
			i.BoostByPos(i.Position, "attack", 2, "enemy") # Boost attack
			i.BoostByPos(i.Position, "health", 1, "enemy") # Boost health

