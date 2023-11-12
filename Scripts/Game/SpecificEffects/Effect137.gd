extends Node

var GameController


func _ready():
	GameController = get_tree().get_first_node_in_group("GameController")


func Effect(team): # Draw a random dwarf that cost 2 lymph, but he’s cost is 0  and has +1 attack and +1 health
	if team == "player":
		var two_lymph_dwarfs = [104,105,106,107]
		var rnd = randi_range(0, len(two_lymph_dwarfs) - 1)
		
		var scene = load("res://Scenes/Game/Cards/Card.tscn") # Load card resources
		var instance = scene.instantiate() # Instantiate card resources
		instance.CreateCard(CardsList.getCardInfo(two_lymph_dwarfs[rnd]), two_lymph_dwarfs[rnd]) # Getting starter values
		instance.Team = "player" # Set team for new card
		instance.Location = "hand" # Set location for new card
		instance.isEnabled = true
		
		GameController.add_child(instance) # Create card
		GameController.player_hand.append(instance)
		
		GameController.UpdateHand()
		
		GameController.player_hand[-1].BoostByPos(GameController.player_hand[-1].Position, "cost", -GameController.player_hand[-1].Cost, "player") # Set free
		GameController.player_hand[-1].BoostByPos(GameController.player_hand[-1].Position, "health", 1, "player") # Gain health
		GameController.player_hand[-1].BoostByPos(GameController.player_hand[-1].Position, "attack", 1, "player") # Gain attack
		
		GameController.player_hand[-1].UpdateStats(GameController.player_hand[-1])
		
		get_tree().call_group("ClientInstance", "send_draw") # Send to opponent you drawed
