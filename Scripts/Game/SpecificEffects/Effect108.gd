extends Node

var GameController
var array_temp = []


func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")


func Effect(team, _position): # When played give +2 attack to one another dwarf
	for x in GameController.player_field_cards: # if there's dwarfs then add them to the array
		if x.Gene == "Dwarf":
			array_temp.append(x)
	
	if team == "player" and len(array_temp) > 0:
		var rnd = randi_range(0, len(array_temp) - 1)
		
		get_tree().call_group("ClientInstance", "send_effect_108", array_temp[rnd].Position) # Send to opponent the card's position to boost
		
		array_temp[rnd].BoostByPos(array_temp[rnd].Position, "attack", 2, "player") # Boost attack # Gain 2 attack
