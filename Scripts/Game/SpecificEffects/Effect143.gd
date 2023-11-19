extends Node

var GameController
var array_of_positions = []


func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")


func Effect(team): # Fill your attack field with Loyal Drudges
	if team == "player":
		for i in GameController.positionStatus:
			if int(i) % 2 != 0 and GameController.positionStatus[i] == null:
				array_of_positions.append(i)
				
				var scene = load("res://Scenes/Game/Cards/Card.tscn") # Load card resources
				var instance = scene.instantiate() # Instantiate card resources
				
				GameController.player_field_cards.append(instance) # Save card instance
				GameController.player_field_cards[-1].CreateCard(CardsList.getCardInfo(134), 134) # Getting starter values
				GameController.player_field_cards[-1].Team = "player" # Set team for new card
				GameController.player_field_cards[-1].Position = i # Set position for new card
				GameController.player_field_cards[-1].Location = "field" # Set location for new card
				
				GameController.player_field_cards[-1].ShiftBack()
				GameController.player_field_cards[-1].SetOnMini()
				
				GameController.add_child(GameController.player_field_cards[-1]) # Create card
				
				var positioner_pos = get_tree().get_first_node_in_group("PP"+str(i)) # Get the right position
				GameController.player_field_cards[-1].global_position = positioner_pos.global_position # Move card to the right position
				
				GameController.positionStatus[i] = GameController.player_field_cards[-1]
				
				GameController.enemy_field_cards.append(GameController.player_field_cards[-1]) # Add card to the array to simplify the founding of it
		
		get_tree().call_group("ClientInstance", "send_effect_143", array_of_positions) # Send to opponent cards to spawn

