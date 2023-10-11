extends Node

@export var client_id = "client1"

var socket = WebSocketPeer.new()

var first = true

var game_scene
var game_instance

var GameController # Game controller reference
var GUI_Manager # GUI manager reference


### MAIN EVENTS ###


func _ready():
	socket.connect_to_url("ws://192.168.1.81:8765")
	#socket.connect_to_url("ws://127.0.0.1:8765")


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
	
	elif message["type"] == "move": # Opponent moved a card into the field
		GameController.MoveEnemyCard(message["old_pos"], message["new_pos"])
		return
	
	elif message["type"] == "attack": # Opponent choose attackers and targets
		GameController.enemy_attacks = message["attacker_list"]
		GameController.FormatAttackerAndDefenders()
		GameController.ManagePlayerDefense()
		return
	
	elif message["type"] == "defende": # Opponent choose defenders
		GameController.enemy_defends = message["defender_list"]
		GameController.FormatAttackerAndDefenders()
		GameController.ManageEnemyDefense()
		return
	
	elif message["type"] == "pass": # Opponent passed phase or turn
		GameController.TurnButtonPressed() # Phase passed
		GUI_Manager._on_Update()
		return
	
	elif message["type"] == "OPPONENT_DISCONNECTED": # Opponent left the game
		GameController.GameEnds("enemy") # You win!
		return


### GAME MESSAGES ###


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
		"type": "defender",
		"id": client_id,
		"defender_list": defender_list,
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

