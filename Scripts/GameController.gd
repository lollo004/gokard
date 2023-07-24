extends Control

### Game Values ###

@export var player_healt : int = 30
@export var enemy_healt : int = 30
@export var lymph : int = 0
@export var stress : int = 0
@export var turn : String = ""
@export var phase : String = ""

var current_max_lymph : int = 0

var player_current_stress : int = 0
var enemy_current_stress : int = 0

var max_lymph : int = 10
var max_stress : int = 9

var turnType : String = "" # Action to do in current turn (play, draw, lymph, stress)

var player_hand = []
var player_deck = []

var isScreenTaken = true # Variable to check if you can interact with buttons

## Attack Variables ##

var started_attack_card # the card that is attacing
var selected_card_to_attack # the card that is selected by the pointer

var player_attacks = {} # Dict with who is attacing who (attacker_pos : defender_pos)
var enemy_attacks = {} # Dict with who is attacing who (attacker_pos : defender_pos)

## Defende Variables ##

var started_defende_card # the card that is choosing to defende or not

var player_defends = [] # List with who is defending
var enemy_defends = [] # List with who is defending

### MAIN EVENTS ###


func _ready():
	var scene
	var instance
	
	for i in 30:
		scene = load("res://Scenes/Cards/Card.tscn")
		instance = scene.instantiate()
		instance.Team = "player"
		
		player_deck.append(instance)
	
	var number_of_cards = 9
	
	for i in number_of_cards:
		add_child(player_deck[i])
		player_hand.append(player_deck[i])
		player_deck.remove_at(i)
		
	UpdateHand()
	
	get_tree().get_first_node_in_group("TurnManager").visible = true
	current_max_lymph = lymph


func _process(delta):
	pass


### PUBLIC FUNCTION ###


func TurnButtonPressed():
	if turn == "enemy" and phase == "attack":
		turn = "player"
		phase = "defense"
		get_tree().call_group("Card", "onTurnBegin", "player")
		
		get_tree().get_first_node_in_group("TurnManager").visible = true
		get_tree().call_group("Deactivable", "Enable", false)
		
		lymph = current_max_lymph
	
	elif turn == "player" and phase == "defense":
		phase = "attack"
		get_tree().call_group("Card", "onPhaseBegin", "player")
	
	elif turn == "player" and phase == "attack":
		turn = "enemy"
		phase = "defense"
		get_tree().call_group("Card", "onTurnBegin", "enemy")
	
	elif turn == "enemy" and phase == "defense":
		phase = "attack"
		get_tree().call_group("Card", "onPhaseBegin", "enemy")


### TURN MANAGEMEN FUNCTIONS ###


func PlayCard():
	if len(player_hand) > 0:
		turnType = "play"

func DrawCard():
	if len(player_deck) > 0 and len(player_hand) < 10:
		turnType = "draw"
		DrawOneCard()
		UpdateHand()

func AddLymph():
	if lymph < max_lymph:
		turnType = "lymph"
		lymph += 1
		current_max_lymph += 1

func AddStress():
	if stress < max_stress:
		turnType = "stress"
		stress += 1


### OTHER FUNCTIONS ###

func DrawOneCard():
	if len(player_deck) > 0 and len(player_hand) < 10:
		player_hand.append(player_deck[-1])
		add_child(player_deck[-1])
		player_deck.remove_at(player_deck.size() - 1)

func UpdateHand():
	var i : int = 0
	
	for item in player_hand:
		i += 1
		if len(player_hand) % 2 == 0:
			item.global_position = Vector2((540 - ((len(player_hand) / 2) * 46)) + (46*i), 520)
		else:
			item.global_position = Vector2((520 - (((len(player_hand) - 1) / 2) * 46)) + (46*i), 520)

func ShuffleDeck():
	player_deck.shuffle()

func Enable(flag : bool): # Function called when a menu is appearing or disappearing
	isScreenTaken = not flag

