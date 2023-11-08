extends Node

var GameController
var card

var list_of_card_to_boost = [] #array of card's position to boost
var array_temp = [] #array used to copy the enemy card's array


func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")
	card = get_parent().get_parent()


func Effect(team, _position): # When played do 1 damage to 3 different enemy 
	array_temp = [] + GameController.enemy_field_cards
	
	if team == "player" and len(array_temp) > 0:
		if len(array_temp) > 0:
			if len(array_temp) <= 3: # there are 1 to 3 cards so you can boost them all
				for c in array_temp: # for each one copy the field position
					list_of_card_to_boost.append(c.Position)
					c.BoostByPos(c.Position, "health", -1, "enemy") # Do damage
			else: # there are more than 3 cards so choose only 3
				for i in range(3):
					var rnd = randi_range(0, len(array_temp) - 1)
					
					list_of_card_to_boost.append(array_temp[rnd].Position) # Remember who has been boosted
					array_temp[rnd].BoostByPos(array_temp[rnd].Position, "health", -1, "enemy") # Do damage
					
					array_temp.erase(array_temp[rnd])
			
			get_tree().call_group("ClientInstance", "send_effect_123", list_of_card_to_boost) # Send to opponent cards to boost
