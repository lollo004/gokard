extends Node

var GameController
var card

var current_phase = 0
var max_phase = 0


func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")
	card = get_parent().get_parent()
	
	max_phase = card.phase_or_turn_mutation


func Effect(): # Phase / Turn Mutation
	if card.Location == "field":
		current_phase += 1
		
		card.Effect = "Phase Mutation (" + str(max_phase - current_phase) + ")"
		card.UpdateStats(card)
		
		if current_phase >= max_phase:
			var scene = load("res://Scenes/Game/Cards/Card" + str(card.mutation_id) + ".tscn") # Load card resources
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
			
			card.queue_free() #Delete the old one
