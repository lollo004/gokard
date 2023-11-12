extends Node

var GameController

var list_of_card_to_damage = [] #array of card's position to boost
var array_temp = [] #array used to copy the card's array


func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")


func Effect(team): # Deal 1 damage to 2 random enemy
	if team == "player":
		array_temp = [] + GameController.enemy_field_cards
		list_of_card_to_damage.clear()

		if len(array_temp) > 0:
			if len(array_temp) <= 2: # there are 1 to 2 cards so you can damage them all
				for c in array_temp: # for each one copy the field position
					list_of_card_to_damage.append(c.Position)
					c.BoostByPos(c.Position, "health", -1, "enemy") # Do damage
			else: # there are more than 2 cards so choose only 2
				for i in range(2):
					var rnd = randi_range(0, len(array_temp) - 1)
					
					list_of_card_to_damage.append(array_temp[rnd].Position) # Remember who has been boosted
					array_temp[rnd].BoostByPos(array_temp[rnd].Position, "health", -1, "enemy") # Do damage
					
					array_temp.erase(array_temp[rnd])
			
			get_tree().call_group("ClientInstance", "send_effect_135", list_of_card_to_damage) # Send to opponent cards to boost

