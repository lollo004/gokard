extends Node

var GameController
var card


func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")
	card = get_parent().get_parent()


func Effect(who, _death, _n): # After he attacks he deal 1 damage to an enemy
	if who.Team == "player" and card == who and len(GameController.enemy_field_cards) > 0:
		var rnd = Data.RANDOM.randi_range(0, len(GameController.enemy_field_cards) - 1)
		
		#get_tree().call_group("ClientInstance", "send_effect_104", GameController.enemy_field_cards[rnd].Position) # Send to opponent the card's position to damage
		
		GameController.enemy_field_cards[rnd].BoostByPos(GameController.enemy_field_cards[rnd].Position, "health", -1, "enemy") # Deal 1 damage
	if who.Team == "enemy" and card == who and len(GameController.player_field_cards) > 0:
		var rnd = Data.RANDOM.randi_range(0, len(GameController.player_field_cards) - 1)
		
		#get_tree().call_group("ClientInstance", "send_effect_104", GameController.enemy_field_cards[rnd].Position) # Send to opponent the card's position to damage
		
		GameController.player_field_cards[rnd].BoostByPos(GameController.player_field_cards[rnd].Position, "health", -1, "player") # Deal 1 damage

