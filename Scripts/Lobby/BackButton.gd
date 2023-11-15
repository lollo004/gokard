extends Node

var scene
var instance


func _on_back_pressed():
	var d = get_tree().get_first_node_in_group("Deck")
	
	d.decks["0"] = d.current_deck_pos # save deck to play in the '0' position
	
	Data.deck.clear() # remove all instances
	
	for i in d.decks[d.current_deck_pos]:
		var card_info = CardsList.getCardInfo(int(i))
		
		if card_info["magic"]:
			scene = load("res://Scenes/Game/Cards/Magic.tscn")
		else:
			scene = load("res://Scenes/Game/Cards/Card.tscn")
		instance = scene.instantiate()
		instance.CreateCard(card_info, int(i))
		instance.Team = "player"
		
		Data.deck.append(instance)
	
	# PERSISTENT DATA SAVE
	
	var save_game = FileAccess.open("user://quoreroccia.save", FileAccess.WRITE)
	var json_string = JSON.stringify(d.decks)
	
	save_game.store_line(json_string) # Store the save dictionary as a new line in the save file.
	
	get_tree().change_scene_to_file("res://Scenes/Lobby/MainMenu.tscn")

