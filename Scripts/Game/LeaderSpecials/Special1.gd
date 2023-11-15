extends Node

var GameController


func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")


func UsePlayerEffect(): # +1 health to all your defense dwarfs
	print("!!! - !!! PLAYER ! SPECIAL !!! - !!!")
	
	for i in GameController.player_field_cards:
		if int(i.Position) % 2 == 0 and i.Gene == "Dwarf":
			i.BoostByPos(i.Position, "health", 1, "player") # Boost health


func UseEnemyEffect(): # +1 health to all your defense dwarfs
	print("!!! - !!! ENEMY ! SPECIAL !!! - !!!")
	
	for i in GameController.enemy_field_cards:
		if int(i.Position) % 2 == 0 and i.Gene == "Dwarf":
			i.BoostByPos(i.Position, "health", 1, "enemy") # Boost health
