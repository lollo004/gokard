extends Node

var list_of_showed_cards = []
var list_of_deck_cards = []

var pos_x = 280 # start from 280 and add 160 each time
var pos_y = 200 # start from 200 and add 150 each time
var isReady = true

var decks = {}
var current_deck_pos = "1"

var currentGene = "Dwarf"
var currentCost = 999


func _ready():
	ShowCards(currentGene, currentCost)
	
	decks = Data.decks.duplicate()
	
	UpdateDeck()


func ShowCards(gene, cost): # Select card to show
	isReady = false
	
	var scene
	var instance
	var counter = 0
	
	for card in Data.card_recurrences:
		var card_info = CardsList.getCardInfo(int(card))
		
		if card_info["canBePlayed"] and card_info["gene"] == gene and (card_info["cost"] == cost or cost == 999):
			if card_info["magic"]:
				scene = load("res://Scenes/Game/Cards/Magic.tscn")
			else:
				scene = load("res://Scenes/Game/Cards/Card.tscn")
			
			instance = scene.instantiate()
			instance.CreateCard(card_info, int(card))
			instance.Team = "player"
			instance.Location = "lobby"
			instance.inGame = false
			instance.z_index = -2
			
			instance.position = Vector2(280 + 160*(counter%4), 200 + 150*floor(counter/4.0))
			add_child(instance)
			
			list_of_showed_cards.append(instance)
			
			counter += 1
	
	isReady = true


func _on_input_event(_viewport, event, _shape_idx, type): # Player mouse scroll
	if event is InputEventMouseButton:
		if event.is_pressed() and isReady:
			if len(list_of_showed_cards) > 0 and type == "Total":
				if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and list_of_showed_cards[-1].position.y >= 200:
					for i in list_of_showed_cards:
						i.position.y = lerp(i.position.y, i.position.y - 50, 0.5)
				if event.button_index == MOUSE_BUTTON_WHEEL_UP and list_of_showed_cards[0].position.y <= 200:
					for i in list_of_showed_cards:
						i.position.y = lerp(i.position.y, i.position.y + 50, 0.5)
			if len(list_of_deck_cards) > 0 and type == "Deck":
				if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and list_of_deck_cards[-1].position.y >= 150:
					for i in list_of_deck_cards:
						i.position.y = lerp(i.position.y, i.position.y - 50, 0.5)
				if event.button_index == MOUSE_BUTTON_WHEEL_UP and list_of_deck_cards[0].position.y <= 150:
					for i in list_of_deck_cards:
						i.position.y = lerp(i.position.y, i.position.y + 50, 0.5)


func _on_gene_pressed(gene): # Change gene
	isReady = false
	
	currentGene = gene
	
	get_tree().call_group("Card", "queue_free")
	list_of_showed_cards.clear()
	
	ShowCards(currentGene, currentCost)
	
	isReady = true


func _on_deck_pressed(n): # Change deck
	if not decks.has(n):
		decks[n] = []
	
	current_deck_pos = n
	
	UpdateDeck()


func UpdateDeck(): # Update UI
	isReady = false
	
	var ctr = 0
	
	get_tree().call_group("Card UI", "queue_free") # delete existing cards
	list_of_deck_cards.clear()
	
	for k in list_of_showed_cards: # reset the counter
		k.times_in_deck[current_deck_pos] = 0
	
	for i in decks[current_deck_pos]:
		for j in list_of_showed_cards: # for each card in your deck avoid player to select it too much times
			if j.id == i:
				j.times_in_deck[current_deck_pos] += 1
		
		var scene = load("res://Scenes/Game/Cards/DeckCardUI.tscn")
		var instance = scene.instantiate()
		var c_info = CardsList.getCardInfo(int(i))
		
		instance.CreateUID(i, c_info["name"], c_info["effect"])
		instance.position = Vector2(890,150+(65*ctr))
		
		add_child(instance)
		
		list_of_deck_cards.append(instance)
		
		ctr += 1
	
	isReady = true

