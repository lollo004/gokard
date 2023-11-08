extends Node

var GameController
var card


func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")
	card = get_parent().get_parent()


func Effect(attacker): # When attacked by an enemy will protect himself anyway
	if card.actionDuringDefense != "defende": #protect only if he's not already protecting himself
		card.ProtectByEnemy(attacker)
