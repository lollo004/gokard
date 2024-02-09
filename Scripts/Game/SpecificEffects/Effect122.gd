extends Node

var GameController
var card

#var list_of_card_to_boost = [] #array of card's position to boost
var array_temp = [] #array used to copy the card's array


func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")
	card = get_parent().get_parent()


func Effect(_team, _pos): # When played give +2 attack to one another dwarf on your field and +1 health to 2 other dwarf on your field
	if card.Location == "field":
		if card.Team == "player":
			for x in GameController.player_field_cards: # if there's dwarfs then add them to the array
				if x.Gene == "Dwarf":
					array_temp.append(x)
			
			if len(array_temp) > 0:
				var rnd = Data.RANDOM.randi_range(0, len(array_temp) - 1)
				
				array_temp[rnd].BoostByPos(array_temp[rnd].Position, "attack", 2, "player") # Gain 2 attack
				
				#get_tree().call_group("ClientInstance", "send_effect_122_1", array_temp[rnd].Position) # Send to opponent the card's position to boost
				
				array_temp.erase(array_temp[rnd])
				
				if len(array_temp) > 0:
					if len(array_temp) <= 2: # there are 1 to 2 cards so you can boost them all
						for c in array_temp: # for each one copy the field position
							#list_of_card_to_boost.append(c.Position)
							c.BoostByPos(c.Position, "health", 1, "player") # Boost health
					else: # there are more than 2 cards so choose only 2
						for i in range(2):
							rnd = Data.RANDOM.randi_range(0, len(array_temp) - 1)
							
							#list_of_card_to_boost.append(array_temp[rnd].Position) # Remember who has been boosted
							array_temp[rnd].BoostByPos(array_temp[rnd].Position, "health", 1, "player") # Boost health
							
							array_temp.remove_at(rnd)
					
					#get_tree().call_group("ClientInstance", "send_effect_122_2", list_of_card_to_boost) # Send to opponent cards to boost
		if card.Team == "enemy":
			for x in GameController.enemy_field_cards: # if there's dwarfs then add them to the array
				if x.Gene == "Dwarf":
					array_temp.append(x)
			
			if len(array_temp) > 0:
				var rnd = Data.RANDOM.randi_range(0, len(array_temp) - 1)
				
				array_temp[rnd].BoostByPos(array_temp[rnd].Position, "attack", 2, "enemy") # Gain 2 attack
				
				#get_tree().call_group("ClientInstance", "send_effect_122_1", array_temp[rnd].Position) # Send to opponent the card's position to boost
				
				array_temp.erase(array_temp[rnd])
				
				if len(array_temp) > 0:
					if len(array_temp) <= 2: # there are 1 to 2 cards so you can boost them all
						for c in array_temp: # for each one copy the field position
							#list_of_card_to_boost.append(c.Position)
							c.BoostByPos(c.Position, "health", 1, "enemy") # Boost health
					else: # there are more than 2 cards so choose only 2
						for i in range(2):
							rnd = Data.RANDOM.randi_range(0, len(array_temp) - 1)
							
							#list_of_card_to_boost.append(array_temp[rnd].Position) # Remember who has been boosted
							array_temp[rnd].BoostByPos(array_temp[rnd].Position, "health", 1, "enemy") # Boost health
							
							array_temp.remove_at(rnd)
					
					#get_tree().call_group("ClientInstance", "send_effect_122_2", list_of_card_to_boost) # Send to opponent cards to boost
