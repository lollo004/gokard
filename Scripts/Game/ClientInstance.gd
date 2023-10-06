extends Node

@export var client_id = "client1"

var socket = WebSocketPeer.new()

var first = true

func _ready():
	socket.connect_to_url("ws://localhost:8765")

func _process(_delta):
	socket.poll()
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		if first: # Now connected
			first = false
			register_client("ABCDEFG") # Now registered
			join_game_queue() # Now queue joined
		
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

func register_client(token):
	var registration_message = {
		"type": "register",
		"id": client_id,
		"token": token
	}
	
	socket.send_text(JSON.stringify(registration_message))

func join_game_queue():
	var join_message = {
		"type": "join",
		"id": client_id
	}
	
	socket.send_text(JSON.stringify(join_message))

func send_message_to_opponent(type, action = null, card_id = null, card_atk = null, deck = null, name = "player"):
	var join_message = {
		"type": type,
		"id": client_id,
		"action": action,
		"card_id": card_id,
		"card_atk": card_atk,
		"deck" : deck,
		"name" : name
	}
	
	socket.send_text(JSON.stringify(join_message))

func handle_new_message(message):
	# Check message type and choose what to do
	print("Message recived from server: ", message)
	
	
	if message["type"] == "joined_queue": # Queue joined
		print("Queue joined!")
		return
	if message["type"] == "game_found": # Game found
		print("Game found --> ", "p1: ", message["p1"], " | p2: ", message["p2"])
		send_message_to_opponent("deck", null, null, null, [1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3], "simomine")
		return
	if message["type"] == "game_start": # Lobby joined and game now ready to start (all informations needed already obtained)
		print("Game Started!")
		load("res://Scenes/Game/MainScene.tscn")
		return
	if message["type"] == "draw":
		send_message_to_opponent("draw", "test")
		return
	if message["type"] == "play":
		send_message_to_opponent("play", "ok...")
		return
