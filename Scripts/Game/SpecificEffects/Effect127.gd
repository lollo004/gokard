extends Node

var GameController
var card


func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")
	card = get_parent().get_parent()


func Effect(stats, value, who): # When one of your cards increment the attack stats gain +1 attack but if the card it's a dwarf also gain +1 health
	if stats == "attack" and value > 0 and who.id != card.id and card.Location == "field":
		card.BoostByPos(card.Position, "attack", 1, card.Team) # Gain +1 attack
		if who.Gene == "Dwarf":
			card.BoostByPos(card.Position, "health", 1, card.Team) # Gain +1 health
