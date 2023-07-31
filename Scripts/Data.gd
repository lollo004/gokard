extends Node

#### PUBLIC STATIC FUNCTION ALWAYS LOADED IN ALL THE SCENE ####

var card_recurrences = {} # cards owned by the player

var total_number_of_cards = 300 # total number of cards in all the game

var deck = [] # cards used during game


func _ready():
	for i in total_number_of_cards:
		card_recurrences[i] = 0 # when a player database will be ready then download number of card possessed
	
	print("Game Ready!") # control account and related stats

