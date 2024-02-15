extends Node

var GameController
var array_temp = [] #array used to copy the card's array
var final_array = [] #array used to save who have to die


func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")


func Effect(team): # Destroy all enemies that has less then 5 attack (can't be applied for the leader)
	if team == "player":
		array_temp = [] + GameController.enemy_field_cards
		final_array = []
		
		for o in array_temp: # remove object with less than 5 attack or it's a leader
			if o.Attack < 5 and not o.isLeader:
				final_array.append(o)
		
		for c in final_array: # for each one copy the field position
			c.BoostByPos(c.Position, "health", -c.Health, "enemy") # Kill
		
		#get_tree().call_group("ClientInstance", "send_effect_138") # Send to opponent cards to boost
	if team == "enemy":
		array_temp = [] + GameController.player_field_cards
		final_array = []
		
		for o in array_temp: # remove object with less than 5 attack or it's a leader
			if o.Attack < 5 and not o.isLeader:
				final_array.append(o)
		
		for c in final_array: # for each one copy the field position
			c.BoostByPos(c.Position, "health", -c.Health, "player") # Kill
		
		#get_tree().call_group("ClientInstance", "send_effect_138") # Send to opponent cards to boost

