extends Node

var GameController
var card


func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")
	card = get_parent().get_parent()


func Effect(): # When he dies summon a hyena 7/7/10/34
	var scene = load("res://Scenes/Game/Cards/Card101.tscn") # Load card resources //CHANGE WITH HYENA
	var instance = scene.instantiate() # Instantiate card resources
	
	instance.Position = card.Position # Set in-game position for new card
	instance.Location = "field" # Set location for new card
	instance.isFirstTurn = false
	instance.position = card.position # Set real position for new card
	
	if card.Team == "player":
		instance.Team = "player" # Set team for new card
		GameController.player_field_cards.erase(card)
		GameController.player_field_cards.append(instance)
	if card.Team == "enemy":
		instance.Team = "enemy" # Set team for new card
		GameController.enemy_field_cards.erase(card)
		GameController.enemy_field_cards.append(instance)
	
	GameController.add_child(instance) # Create card
