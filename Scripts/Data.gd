extends Node

#### PUBLIC STATIC FUNCTION ALWAYS LOADED IN ALL THE SCENE ####

var nickname = "SimoMine"

var RANDOM = RandomNumberGenerator.new()

var card_recurrences = {} # cards owned by the player

var total_number_of_cards = 300 # total number of cards in all the game

var deck = [] # cards used during game
var decks = {"1":[], "2":[], "3":[], "4":[]} # all your decks
var player_back = null # back of the card
var initial_number_player_cards = 0 # number of cards when game start
var leader_id = 11
var leader_pos = "5"

var enemy_back_deck = [] # back of the card
var initial_number_enemy_cards = 0 # number of cards when game start


func _ready():
	var c = 0
	
	for i in total_number_of_cards:
		if c >= 101 and c <= 145:
			card_recurrences[i] = 3 # when a player database will be ready then download number of card possessed
		c += 1
	
	## ONLY_FOR_DEBUG RANDOM HAND GEN ##
#	var scene
#	var instance
#
#	for i in 30:
#		var rng = RandomNumberGenerator.new()
#		var number = rng.randi_range(101, 144)
#		#var number = rng.randi_range(122, 122)
#		#var number = rng.randi_range(106, 106)
#
#		var card_info = CardsList.getCardInfo(int(number))
#
#		if card_info["magic"]:
#			scene = load("res://Scenes/Game/Cards/Magic.tscn")
#		else:
#			scene = load("res://Scenes/Game/Cards/Card.tscn")
#		instance = scene.instantiate()
#		instance.CreateCard(card_info, int(number))
#		instance.Team = "player"
#
#		deck.append(instance)
	
	player_back = load("res://Scenes/Game/Cards/BackCard.tscn").instantiate()
	
	initial_number_player_cards = 4
	
	## ONLY_FOR_DEBUG ENEMY SETUP ##
	
	for i in 30:
		enemy_back_deck.append(load("res://Scenes/Game/Cards/BackCard.tscn").instantiate())
	
	initial_number_enemy_cards = 4
	
	## LOAD DECKS SAVED INTO CASH ##
	
	CreateCurrentDeck()
	
	print("Game Ready!") # control account and related stats


func CreateCurrentDeck():
	if not FileAccess.file_exists("user://leaflords.save"):
		print("No saves to load!")
	else:
		print("Decks loaded!")
		
		deck.clear()
		
		var save_game = FileAccess.open("user://leaflords.save", FileAccess.READ)
		var value = JSON.parse_string(save_game.get_line())
		
		for j in value: # save decks from cash
			if j != "0":
				decks[j] = value[j]
	
		for i in decks[value["0"]]: # current deck
			var card_info = CardsList.getCardInfo(int(i))
			var scene
			
			if card_info["magic"]:
				scene = load("res://Scenes/Game/Cards/Magic.tscn")
			else:
				scene = load("res://Scenes/Game/Cards/Card.tscn")
			
			var instance = scene.instantiate()
			instance.CreateCard(card_info, int(i))
			instance.Team = "player"
			
			deck.append(instance)


func isInstanceValid(obj) -> bool:
	if obj == null or str(obj) == "<Freed Object>" or not is_instance_valid(obj) or obj.Health <= 0:
		return false
	else:
		return true
