extends Node

var GameController
var card


func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")
	card = get_parent().get_parent()


func Effect(attacker, target, _n): # When attacked he dies and kill who attacked him (can't be applied for the leader)
	if card == target:
		if not attacker.isLeader:
			attacker.BoostByPos(attacker.Position, "health", -attacker.Health, attacker.Team) # kill the enemy
		card.BoostByPos(card.Position, "health", -card.Health, card.Team) # kill yourself

