extends Node

#### PUBLIC STATIC FUNCTION ALWAYS LOADED IN ALL THE SCENE ####

var nickname = "SimoMine"

var card_recurrences = {} # cards owned by the player

var total_number_of_cards = 300 # total number of cards in all the game

var deck = [] # cards used during game
var player_back = null # back of the card
var initial_number_player_cards = 0 # number of cards when game start

var enemy_back_deck = [] # back of the card
var initial_number_enemy_cards = 0 # number of cards when game start


func _ready():
	for i in total_number_of_cards:
		card_recurrences[i] = 0 # when a player database will be ready then download number of card possessed
	
	## ONLY_FOR_DEBUG RANDOM HAND GEN ##
	var scene
	var instance
	
	for i in 30:
		var rng = RandomNumberGenerator.new()
		var number = rng.randi_range(101, 133)
		
		scene = load("res://Scenes/Game/Cards/Card.tscn")
		instance = scene.instantiate()
		instance.CreateCard(CardsList.getCardInfo(int(number)), int(number))
		instance.Team = "player"
		
		deck.append(instance)
	
	player_back = load("res://Scenes/Game/Cards/BackCard.tscn").instantiate()
	
	initial_number_player_cards = 4
	
	## ONLY_FOR_DEBUG ENEMY SETUP ##
	
	for i in 30:
		enemy_back_deck.append(load("res://Scenes/Game/Cards/BackCard.tscn").instantiate())
	
	initial_number_enemy_cards = 4
	
	print("Game Ready!") # control account and related stats

