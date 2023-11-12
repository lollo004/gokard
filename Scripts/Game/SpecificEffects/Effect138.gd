extends Node

var GameController
var array_temp = [] #array used to copy the card's array


func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")


func Effect(team): # Destroy 2 random enemies that has less then 10 attack
	if team == "player":
		array_temp = [] + GameController.enemy_field_cards
		
		for o in array_temp: # remove object with more than 9 attack
			if o.Attack >= 10:
				array_temp.erase(o)
		
		for c in array_temp: # for each one copy the field position
			c.BoostByPos(c.Position, "health", -c.Health, "enemy") # Kill
		
		get_tree().call_group("ClientInstance", "send_effect_138") # Send to opponent cards to boost

