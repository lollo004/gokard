extends Node

var GameController
var pos_to_send

var death_attackers = []
var death_defenders = []
var death_versatiles = []

var final_array = []

var free_atk : bool
var free_def : bool

func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")


func Effect(team): # Summon a random dead ally dwarf
	if team == "player":
		if len(GameController.player_field_cards) < 9 and len(GameController.player_deaths) > 0:
			for j in range(1,10): # control which places are free
				if GameController.positionStatus[str(j)] == null:
					if j % 2 == 0: #defenders
						free_atk = true
					else: #attackers
						free_def = true
			
			
			for a in GameController.player_deaths: #divide deaths by type
				var scene = load("res://Scenes/Game/Cards/Card.tscn") # Load card resources
				var instance = scene.instantiate() # Instantiate card resources
				
				instance.CreateCard(CardsList.getCardInfo(int(a)), int(a)) # Getting starter values
				
				instance.ShiftBack()
				instance.SetOnMini()
				
				if instance.Type == "Attack":
					death_attackers.append(instance)
				if instance.Type == "Defense":
					death_defenders.append(instance)
				if instance.Type == "Versatile":
					death_versatiles.append(instance)
			
			if len(death_attackers) > 0 and free_atk == true:
				final_array += death_attackers
			if len(death_defenders) > 0 and free_def == true:
				final_array += death_defenders
			final_array += death_versatiles
			
			var rnd = randi_range(0, len(final_array) - 1)
			
			GameController.player_field_cards.append(final_array[rnd]) # Save card instance
			
			for i in range(1,10): # 1-9
				if (
					GameController.positionStatus[str(i)] == null and 
					(
						(final_array[rnd].Type == "Attack" and i % 2 != 0) or
						(final_array[rnd].Type == "Defense" and i % 2 == 0) or
						final_array[rnd].Type == "Versatile"
					)
					):
					pos_to_send = i
					
					GameController.player_field_cards[-1].Team = "player" # Set team for new card
					GameController.player_field_cards[-1].Position = str(i) # Set position for new card
					GameController.player_field_cards[-1].Location = "field" # Set location for new card
					
					GameController.add_child(GameController.player_field_cards[-1]) # Create card
					
					var positioner_pos = get_tree().get_first_node_in_group("PP"+str(i)) # Get the right position
					GameController.player_field_cards[-1].global_position = positioner_pos.global_position # Move card to the right position
					
					GameController.positionStatus[str(i)] = GameController.player_field_cards[-1]
					
					get_tree().call_group("ClientInstance", "send_effect_142", pos_to_send, final_array[rnd].id) # Send to opponent cards to spawn
					
					return # stop the 'for loop'

