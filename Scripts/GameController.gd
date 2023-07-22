extends Control

### GAME VALUES ###

@export var player_healt : int = 30
@export var enemy_healt : int = 30
@export var lymph : int = 0
@export var stress : int = 0
@export var turn : String = "player"
@export var phase : String = "defense"

var current_max_lymph : int = 0

var player_current_stress : int = 0
var enemy_current_stress : int = 0

var max_lymph : int = 10
var max_stress : int = 9

var turnType : String = "" # Action to do in current turn (play, draw, lymph, stress)

var player_hand = []

var player_deck = []

### MAIN EVENTS ###


func _ready():
	var scene
	var instance
	
	var number_of_cards = 10
	
	for i in number_of_cards:
		scene = load("res://Scenes/Cards/Card.tscn")
		
		instance = scene.instantiate()
		add_child(instance)
		
		player_hand.append(instance)
		
	UpdateHand()
	
	get_tree().get_first_node_in_group("TurnManager").visible = true
	current_max_lymph = lymph


func _process(delta):
	pass


### PUBLIC FUNCTION ###


func TurnButtonPressed():
	if phase == "defense":
		phase = "attack"
	else:
		phase = "defense"
		if turn == "player":
			turn = "enemy"
		else:
			turn = "player"
			get_tree().get_first_node_in_group("TurnManager").visible = true
			lymph = current_max_lymph


### TURN MANAGEMEN FUNCTIONS ###


func PlayCard():
	if len(player_hand) > 0:
		turnType = "play"
		TurnButtonPressed()

func DrawCard():
	if len(player_deck) > 0:
		turnType = "draw"
		DrawOneCard()

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
	if len(player_deck) > 0:
		player_hand.append(player_deck[0])
		player_deck.remove_at(0)

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
