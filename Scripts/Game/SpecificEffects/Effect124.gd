extends Node

var GameController
var card

var array_temp


func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")
	card = get_parent().get_parent()


func Effect(team, _position, _who): # When enemy spends all the lymph draw a card and if it's a dwarf give it +1 attack, +1 health and reduce the cost by 1
	if card.Location == "field" and team == "enemy" and GameController.lymph == 0:
			var ret = GameController.DrawOneCard()
			
			if ret != null:
				if ret.Gene == "Dwarf":
					ret.BoostByPos(ret.Position, "health", 1, "player") # Gain +1 helath
					ret.BoostByPos(ret.Position, "attack", 1, "player") # Gain +1 attack
					ret.BoostByPos(ret.Position, "cost", -1, "player") # Reduce the cost by one
				
				get_tree().call_group("ClientInstance", "send_draw") # Send to opponent that you drawed
				
				get_tree().call_group("OnDraw", "Effect", "player") # Call 'OnDraw' functions

