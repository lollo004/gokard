extends Node

@export var client_id = "client1" + str(randi_range(1,10000))

var socket = WebSocketPeer.new()

var first = true

var game_scene
var game_instance

var GameController # Game controller reference
var GUI_Manager # GUI manager reference


### MAIN EVENTS ###


func _ready():
	socket.connect_to_url("ws://192.168.1.81:8765")


func _process(_delta):
	socket.poll()
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		if first: # Now connected
			first = false
			register_client("ABCDEFG") # Now registered
		
		while socket.get_available_packet_count():
			handle_new_message(JSON.parse_string(socket.get_packet().get_string_from_utf8()))
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		set_process(false) # Stop processing.


### AUTHORIZE CLIENT ###


func register_client(token):
	var registration_message = {
		"type": "server_event",
		"id": client_id,
		"action" : "register",
		"token": token
	}
	
	socket.send_text(JSON.stringify(registration_message))


func join_game_queue():
	var join_message = {
		"type": "server_event",
		"id": client_id,
		"action" : "join"
	}
	
	socket.send_text(JSON.stringify(join_message))


### MESSAGE HANDLER ###


func handle_new_message(message): # Check message type and choose what to do
	print("Server --> ", message)
	
	if message["type"] == "server_event": # Management message
		if message["action"] == "REGISTER_SUCCESS": # Client registered
			join_game_queue() # Now queue joined
			return
		if message["action"] == "JOINED_QUEUE_SUCCESS": # Queue joined
			return
		if message["action"] == "GAME_FOUND": # Lobby joined and game now ready to start
			# Creating game scene
			game_scene = load("res://Scenes/Game/MainScene.tscn")
			game_instance = game_scene.instantiate()
			add_child(game_instance)
			
			# Getting gamemanager reference
			GameController = get_tree().get_first_node_in_group("GameController")
			GUI_Manager = get_tree().get_first_node_in_group("GUI_Manager")
			
			# Preparing game scene
			GameController.InitialSetupForGameStart(message["name"], message["start"])
			return
	
	if message["type"] == "turn": # Opponent chose turn type
		if message["action"] == "lymph": # Increment lymph
			GameController.lymph += 1
			GameController.current_max_lymph += 1
			GUI_Manager._on_Update()
			return
		if message["action"] == "stress": # Increment stress
			GameController.stress += 1
			GUI_Manager._on_Update()
			return
		if message["action"] == "draw": # Increment enemy hand
			GameController.DrawEnemyCard()
			GUI_Manager._on_Update()
			return
		if message["action"] == "play": # Wait until enemy do something
			GUI_Manager._on_Update()
			return
	
	elif message["type"] == "play": # Opponent played a card from his hand
		GameController.PlayEnemyCard(message["card_id"], message["new_pos"], message["stats"])
		return
	
	elif message["type"] == "magic": # Opponent played a magic from his hand
		GameController.PlayEnemyMagic(message["card_id"])
		return
	
	elif message["type"] == "draw": # Opponent drawed a card
		GameController.DrawEnemyCard()
		return
	
	elif message["type"] == "move": # Opponent moved a card into the field
		GameController.MoveEnemyCard(message["old_pos"], message["new_pos"])
		return
	
	elif message["type"] == "attack": # Opponent choose attackers and targets
		GameController.enemy_attacks = message["attacker_list"]
		GameController.FormatOnDefende()
		GameController.ManagePlayerDefense()
		GameController.player_attacks.clear()
		return
	
	elif message["type"] == "defende": # Opponent choose defenders
		GameController.enemy_defends = message["defender_list"]
		GameController.FormatOnAttack()
		GameController.ManageEnemyDefense()
		GameController.player_defends.clear()
		return
	
	elif message["type"] == "special": # Opponent choose defenders
		GameController.UseEnemySpecial()
		return
	
	elif message["type"] == "pass": # Opponent passed phase or turn
		GameController.TurnButtonPressed() # Phase passed
		GUI_Manager._on_Update()
		return
	
	elif message["type"] == "OPPONENT_DISCONNECTED": # Opponent left the game
		GameController.GameEnds("enemy") # You win!
		get_tree().change_scene_to_file("Scenes/Lobby/MainMenu.tscn")
		return
	
	elif message["type"] == "game_effect": # Opponent do something specific
		if message["action"] == "104": # Opponent tell you who he damaged
			get_tree().call_group("Card", "BoostByPos", message["card"], "health", -1, "player")
			return
		if message["action"] == "108": # Opponent tell you who he boosted
			get_tree().call_group("Card", "BoostByPos", message["card"], "attack", 2, "enemy")
			return
		if message["action"] == "114": # Opponent show you a card
			GameController.ShowOneCard(int(message["card_id"]))
			return
		if message["action"] == "115": # Opponent tell you who he boosted
			for pos in message["cards"]:
				get_tree().call_group("Card", "BoostByPos", pos, "attack", 2, "enemy")
			return
		if message["action"] == "122_1": # Opponent tell you who he boosted
			get_tree().call_group("Card", "BoostByPos", message["card"], "attack", 2, "enemy")
			return
		if message["action"] == "122_2": # Opponent tell you who he boosted
			for pos in message["cards"]:
				get_tree().call_group("Card", "BoostByPos", pos, "health", 1, "enemy")
			return
		if message["action"] == "123": # Opponent tell you who he damaged
			for pos in message["cards"]:
				get_tree().call_group("Card", "BoostByPos", pos, "health", -1, "player")
			return
		if message["action"] == "124": # Opponent tell you that he drawed
			GameController.DrawEnemyCard()
			return
		if message["action"] == "133": # Opponent tell you who he boosted
			get_tree().call_group("Card", "BoostByPos", message["card"], "attack", 3, "enemy")
			get_tree().call_group("Card", "BoostByPos", message["card"], "health", 1, "enemy")
			return
		if message["action"] == "135": # Opponent tell you who he damaged
			for pos in message["cards"]:
				get_tree().call_group("Card", "BoostByPos", pos, "health", -1, "player")
			return
		if message["action"] == "136": # Opponent tell you who he boosted
			for pos in message["cards"]:
				get_tree().call_group("Card", "BoostByPos", pos, "attack", 1, "enemy")
			return
		if message["action"] == "138": # Opponent tell you who he killed
			var array_temp = [] + GameController.player_field_cards # create array
			for o in array_temp: # remove object with more than 9 attack
				if o.Attack >= 10:
					array_temp.erase(o)
			for c in array_temp:
				c.BoostByPos(c.Position, "health", -c.Health, "player") # Kill
			return
		if message["action"] == "139": # Opponent tell you who he boosted
			if message["team"] == "player":
				get_tree().call_group("Card", "BoostByPos", message["pos"], "health", 3, "enemy") # Boost health
			else:
				get_tree().call_group("Card", "BoostByPos", message["pos"], "health", 3, "player") # Boost health
		if message["action"] == "140": # Opponent tell you that he increased the stress
			if GameController.stress < GameController.max_stress:
				GameController.stress += 1
				get_tree().call_group("GUI_Manager", "_on_Update")
		if message["action"] == "141": # Opponent tell you who he boosted
				for pos in message["cards"]:
					get_tree().call_group("Card", "BoostByPos", pos, "attack", 2, "enemy")
					get_tree().call_group("Card", "BoostByPos", pos, "health", 1, "enemy")
				return
		if message["action"] == "142": # Opponent tell you where and who he played
			var scene = load("res://Scenes/Game/Cards/Card.tscn") # Load card resources
			var instance = scene.instantiate() # Instantiate card resources
			GameController.enemy_cards[message["pos"]] = instance # Save card instance
			GameController.enemy_cards[message["pos"]].CreateCard(CardsList.getCardInfo(int(message["card"])), int(message["card"])) # Getting starter values
			GameController.enemy_cards[message["pos"]].Team = "enemy" # Set team for new card
			GameController.enemy_cards[message["pos"]].Position = str(message["pos"]) # Set position for new card
			GameController.enemy_cards[message["pos"]].Location = "field" # Set location for new card
			
			GameController.enemy_cards[message["pos"]].ShiftBack()
			GameController.enemy_cards[message["pos"]].SetOnMini()
			
			GameController.add_child(GameController.enemy_cards[message["pos"]]) # Create card
			
			var positioner_pos = get_tree().get_first_node_in_group("EP"+str(message["pos"])) # Get the right position
			GameController.enemy_cards[message["pos"]].global_position = positioner_pos.global_position # Move card to the right position
			
			GameController.positionStatus[message["pos"]] = GameController.enemy_cards[message["pos"]]
			
			GameController.enemy_field_cards.append(GameController.enemy_cards[message["pos"]]) # Add card to the array to simplify the founding of it
			
			return # stop the for loop
		if message["action"] == "143": # Opponent tell you to spawn the servants
			for i in message["cards"]:
				var scene = load("res://Scenes/Game/Cards/Card.tscn") # Load card resources
				var instance = scene.instantiate() # Instantiate card resources
				GameController.enemy_cards[i] = instance # Save card instance
				GameController.enemy_cards[i].CreateCard(CardsList.getCardInfo(134), 134) # Getting starter values
				GameController.enemy_cards[i].Team = "enemy" # Set team for new card
				GameController.enemy_cards[i].Position = i # Set position for new card
				GameController.enemy_cards[i].Location = "field" # Set location for new card
				
				GameController.enemy_cards[i].ShiftBack()
				GameController.enemy_cards[i].SetOnMini()
				
				GameController.add_child(GameController.enemy_cards[i]) # Create card
				
				var positioner_pos = get_tree().get_first_node_in_group("EP"+str(i)) # Get the right position
				GameController.enemy_cards[i].global_position = positioner_pos.global_position # Move card to the right position
				
				GameController.positionStatus[i] = GameController.enemy_cards[i]
				
				GameController.enemy_field_cards.append(GameController.enemy_cards[i]) # Add card to the array to simplify the founding of it
		if message["action"] == "144": # Opponent tell you who he boosted
			for i in GameController.enemy_field_cards:
				i.BoostByPos(i.Position, "attack", 5, "enemy") # Gain attack
				i.BoostByPos(i.Position, "health", 2, "enemy") # Gain health


### GAME MESSAGES ###


## Main Events ##


func send_turn_choice(action): # Function called when player choose what to do this turn
	var join_message = {
		"type": "turn",
		"id": client_id,
		"action": action
	}
	
	socket.send_text(JSON.stringify(join_message))


func send_play_card(card_id, new_pos, stats = []): # Function called when player play a card from his hand
	var join_message = {
		"type": "play",
		"id": client_id,
		"card_id": card_id,
		"new_pos": new_pos,
		"stats": stats
	}
	
	socket.send_text(JSON.stringify(join_message))


func send_play_magic(card_id): # Function called when player play a magic from his hand
	var join_message = {
		"type": "magic",
		"id": client_id,
		"card_id": card_id,
	}
	
	socket.send_text(JSON.stringify(join_message))


func send_draw(): # Function called when drawed a card not regularly
	var join_message = {
		"type": "draw",
		"id": client_id,
	}
	
	socket.send_text(JSON.stringify(join_message))


func send_move_card(old_pos, new_pos): # Function called when player move a card
	var join_message = {
		"type": "move",
		"id": client_id,
		"old_pos": old_pos,
		"new_pos": new_pos
	}
	
	socket.send_text(JSON.stringify(join_message))


func send_attack(attacker_dict): # Function called when player decide to attack
	var join_message = {
		"type": "attack",
		"id": client_id,
		"attacker_list": attacker_dict
	}
	
	socket.send_text(JSON.stringify(join_message))


func send_defense(defender_list): # Function called when player decide to defende
	var join_message = {
		"type": "defende",
		"id": client_id,
		"defender_list": defender_list,
	}
	
	socket.send_text(JSON.stringify(join_message))


func send_special(): # Function called when player decide to use special
	var join_message = {
		"type": "special",
		"id": client_id,
	}
	
	socket.send_text(JSON.stringify(join_message))


func send_pass(): # Function called when player pass phase
	var join_message = {
		"type": "pass",
		"id": client_id,
	}
	
	socket.send_text(JSON.stringify(join_message))


func send_quit(): # Function called when player quit
	var join_message = {
		"type": "quit",
		"id": client_id,
	}
	
	socket.send_text(JSON.stringify(join_message))


## Specif Cards Effects ##


func send_effect_104(pos): # Function called when you play card with id 104
	var join_message = {
		"type": "game_effect",
		"action": "104",
		"id": client_id,
		"card": pos #position of the card to boost
	}
	
	socket.send_text(JSON.stringify(join_message))


func send_effect_108(pos): # Function called when you play card with id 108
	var join_message = {
		"type": "game_effect",
		"action": "108",
		"id": client_id,
		"card": pos #position of the card to boost
	}
	
	socket.send_text(JSON.stringify(join_message))


func send_effect_114(): # Function called when you play card with id 114
	var join_message = {
		"type": "game_effect",
		"action": "114",
		"id": client_id,
		"card_id": GameController.player_hand[randi_range(0, len(GameController.player_hand) - 1)].id #card
	}
	
	socket.send_text(JSON.stringify(join_message))


func send_effect_115(list): # Function called when you play card with id 115
	var join_message = {
		"type": "game_effect",
		"action": "115",
		"id": client_id,
		"cards": list #list of card to boost
	}
	
	socket.send_text(JSON.stringify(join_message))


func send_effect_122_1(pos): # Function called when you play card with id 122 on first function
	var join_message = {
		"type": "game_effect",
		"action": "122_1",
		"id": client_id,
		"card": pos  #position of the card to boost
	}
	
	socket.send_text(JSON.stringify(join_message))


func send_effect_122_2(list): # Function called when you play card with id 122 on second function
	var join_message = {
		"type": "game_effect",
		"action": "122_2",
		"id": client_id,
		"cards": list #list of card to boost
	}
	
	socket.send_text(JSON.stringify(join_message))


func send_effect_123(list): # Function called when you play card with id 123
	var join_message = {
		"type": "game_effect",
		"action": "123",
		"id": client_id,
		"cards": list #list of card to damage
	}
	
	socket.send_text(JSON.stringify(join_message))


func send_effect_124(): # Function called when you play card with id 124
	var join_message = {
		"type": "game_effect",
		"action": "124",
		"id": client_id,
	}
	
	socket.send_text(JSON.stringify(join_message))


func send_effect_133(pos): # Function called when you play card with id 133
	var join_message = {
		"type": "game_effect",
		"action": "133",
		"id": client_id,
		"card": pos #position of the card to boost
	}
	
	socket.send_text(JSON.stringify(join_message))


func send_effect_135(list): # Function called when you play card with id 135
	var join_message = {
		"type": "game_effect",
		"action": "135",
		"id": client_id,
		"cards": list #list of card to damage
	}
	
	socket.send_text(JSON.stringify(join_message))


func send_effect_136(list): # Function called when you play card with id 136
	var join_message = {
		"type": "game_effect",
		"action": "136",
		"id": client_id,
		"cards": list #list of card to damage
	}
	
	socket.send_text(JSON.stringify(join_message))


func send_effect_138(): # Function called when you play card with id 138
	var join_message = {
		"type": "game_effect",
		"action": "138",
		"id": client_id,
	}
	
	socket.send_text(JSON.stringify(join_message))


func send_effect_139(card, team): # Function called when you play card with id 139
	var join_message = {
		"type": "game_effect",
		"action": "139",
		"id": client_id,
		"pos": card,
		"team": team
	}
	
	socket.send_text(JSON.stringify(join_message))


func send_effect_140(): # Function called when you play card with id 140
	var join_message = {
		"type": "game_effect",
		"action": "140",
		"id": client_id,
	}
	
	socket.send_text(JSON.stringify(join_message))


func send_effect_141(list): # Function called when you play card with id 141
	var join_message = {
		"type": "game_effect",
		"action": "141",
		"id": client_id,
		"cards": list #list of card to damage
	}
	
	socket.send_text(JSON.stringify(join_message))


func send_effect_142(pos, card_id): # Function called when you play card with id 142
	var join_message = {
		"type": "game_effect",
		"action": "142",
		"id": client_id,
		"pos": pos, #position of the card to boost
		"card": card_id
	}
	
	socket.send_text(JSON.stringify(join_message))


func send_effect_143(list): # Function called when you play card with id 143
	var join_message = {
		"type": "game_effect",
		"action": "143",
		"id": client_id,
		"cards": list #list of card to damage
	}
	
	socket.send_text(JSON.stringify(join_message))


func send_effect_144(): # Function called when you play card with id 144
	var join_message = {
		"type": "game_effect",
		"action": "144",
		"id": client_id,
	}
	
	socket.send_text(JSON.stringify(join_message))

