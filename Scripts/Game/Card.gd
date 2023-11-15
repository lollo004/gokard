extends Area2D

## Card Variables ##

@export var Health : int = 0
@export var Attack : int = 0
@export var Speed : int = 0
@export var Weight : int = 0

@export var Cost : int = 0 # Lymph cost

@export var id : int = 0 # Univoc id to represent the card

@export var Name : String = ""

@export var Base : String = "Base" # If it's an evolution write here base card name
@export var BaseId = [] # If it's an evolution write here base card univoque id

@export var Gene : String = ""  # Gene (human - magic - building - ecc.)
@export var Deviation : String = "" # Deviation (standard - mage - sage)

@export var Effect : String = "" # Effect in game

@export var Type : String = "" # Type (Attack - Defense - Versatile)

@export var Team : String = "" # Team (player - enemy)

@export var canAttackEnemies = true
@export var canAttackLeader = true

@export var canBeMoved = true
@export var canUseAbility = true
@export var canBeBuffed = true

@export var turnBlockedOnPlay = 1 # how many turn must pass to use card attack or special

@export var isMagic = false # is the card a magic
@export var isRandom = true # does the magic requires to use the pointer

@export var fusion = false # does card have to fusion to be played
@export var fusionid = [] # list of card's ids to fuse

@export var card_tier = 3 # tier of the card (max repetition of a single cards)

## Management Variables ##

var Position : String = "0" # Position on the field (1-9 => field | 10 => Leader | 0 => Invalid)
var Location : String = "hand" # Location of the card (deck - hand - field - waste)

var turnInGame : int = 0 # Variable used to disable the card on the firsts turn you play it
var isEnabled : bool = false # Variable to check if a card is enabled and you can interact with it

var GameController # Game controller reference

@export var phase_or_turn_mutation = 0 # If he has a mutation here's the number of phases/turns
@export var mutation_id = 0 # If he has a mutations here's the new card's id

var isDead = false # Variable used to avoid that cards can send multiple (inifinite) signals

## Deck Creation Variables ##

var inGame = true # Variable used to check if the card is in game or showed to make deck

var current_deck_ref # Variable used to show cards on your deck

var times_in_deck = {} # Variable used to remeber how many times you used a card

## Scale Variables ##

var minScale
var maxScale
var sprite

## Movement and Selection Variables ##

var isMouseOver : bool = false
var isCardSelected : bool = false
var alreadyMoved : bool = false

var currentPos : String = "0" # Current position on the field (1-9 => field | 10 => Leader | 0 => Invalid)
var old_position # First position of the card
var new_position # New position of the card
var currentLoc : String = "" # Type on the field (attack - defense)

var is_returned_to_hand = true # Used to check if you want to take back your card

## Attack Variables ##

var isTargetSelected : bool = false
var isSearchingForEnemy : bool = false

## Defense Variables ##

var isChooseDone : bool = false
var isChoosingToDefend : bool = false

var actionDuringDefense : String = "" # The action that has been choosen to do when the defending turn is finished (defende - special)
var isBlockedByAbility : bool = false # Variable to check if the card defended or uses special
var hasAbilityBeenUsedThisTurn : bool = false # Variable to check if the card defended or uses special


### MAIN EVENTS ###


func _ready(): # Function called only on start
	if inGame:
		GameController = get_tree().get_first_node_in_group("GameController")
	else:
		current_deck_ref = get_tree().get_first_node_in_group("Deck")


func _process(delta): # Function called every frame
	if isCardSelected and isEnabled: # Drag card with mouse
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta)
		sprite.scale = minScale


### MOUSE EVENTS ###


func _on_mouse_entered(): # Start override with mouse
	sprite.scale = maxScale
	isMouseOver = true
	
	if inGame:
		sprite.z_index = 1
		z_index = 2
	
	if Location == "hand":
		sprite.offset.y -= 700
		for objects in sprite.get_children():
			objects.position.y -= 700
	
	if Team == "player" and inGame:
		GameController.card_counter += 1


func _on_mouse_exited(): # Stop override with mouse
	sprite.scale = minScale
	isMouseOver = false
	
	if inGame:
		sprite.z_index = 0
		z_index = 1
	
	if Location == "hand":
		sprite.offset.y += 700
		for objects in sprite.get_children():
			objects.position.y += 700
	
	if Team == "player" and inGame:
		GameController.card_counter -= 1


func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT and isMouseOver and isEnabled: # Click over a card with left mouse button
			if Team == "player" and GameController.turn == "player":
				if isCardSelected: # Dropping the card
					if not isMagic: # It's not a magic
						if not fusion:
							if (
								currentPos != "0" # Right position
								and GameController.lymph >= Cost # Enough lymph 
								and GameController.turn == "player" # Right turn
								#and GameController.phase == "attack" # Right phase
								and (GameController.turnType == "play" or GameController.turnType == "draw") # Right turn type
								and Location == "hand" # Right card
								and (Type == currentLoc or Type == "Versatile") # Right type
								and not is_returned_to_hand # Right position
								):
									if (
										(len(BaseId) == 0 and GameController.positionStatus[currentPos] == null) # free position
										or 
										(len(BaseId) > 0 and GameController.positionStatus[currentPos] != null and GameController.positionStatus[currentPos].id in BaseId) # his base his on this position
									):
										if len(BaseId) > 0 and GameController.positionStatus[currentPos].id in BaseId: # delete the old one
											GameController.player_field_cards.erase(GameController.positionStatus[currentPos])
											GameController.positionStatus[currentPos].queue_free()
											GameController.card_counter = 1 # remove the deleted card
										
										Location = "field"
										global_position = new_position
										Position = currentPos
										GameController.positionStatus[Position] = self
										
										GameController.lymph -= Cost
										
										GameController.player_hand.erase(self)
										GameController.UpdateHand()
										
										sprite.offset.y += 700 # Adjusting card offset
										for objects in sprite.get_children(): # Adjusting statistics offset
											objects.position.y += 700
										
										get_tree().call_group("GUI_Manager", "_on_Update")
										
										if get_node_or_null("Common Effects/Rise").get_script():
											get_node("Common Effects/Rise").Effect(Team, Position) # Call 'Rise' function of the played card
										get_tree().call_group("OnDeploy", "Effect", Team, Position, self) # Call 'OnDeploy' functions
										
										GameController.player_field_cards.append(self)
										
										get_tree().call_group("ClientInstance", "send_play_card", id, Position) # Send card and position to opponent
									else:
										global_position = old_position
							else:
								global_position = old_position
						else: # It's a fusion
							if (
								currentPos != "0" # Right position
								and GameController.lymph >= Cost # Enough lymph 
								and GameController.turn == "player" # Right turn
								and GameController.phase == "attack" # Right phase
								and (GameController.turnType == "play" or GameController.turnType == "draw") # Right turn type
								and Location == "hand" # Right card
								and (Type == currentLoc or Type == "Versatile") # Right type
								and not is_returned_to_hand # Right position
								and CheckForFusion() # Fusion cards are on the field
								):
									Location = "field"
									global_position = new_position
									Position = currentPos
									GameController.positionStatus[Position] = self
									
									GameController.lymph -= Cost
									
									GameController.player_hand.erase(self)
									GameController.UpdateHand()
									
									sprite.offset.y += 700 # Adjusting card offset
									for objects in sprite.get_children(): # Adjusting statistics offset
										objects.position.y += 700
									
									get_tree().call_group("GUI_Manager", "_on_Update")
									
									if get_node_or_null("Common Effects/Rise").get_script():
										get_node("Common Effects/Rise").Effect(Team, Position) # Call 'Rise' function of the played card
									get_tree().call_group("OnDeploy", "Effect", Team, Position, self) # Call 'OnDeploy' functions
									
									for i in GameController.player_field_cards: # remove bases of fusion
										if i.id in fusionid:
											GameController.player_field_cards.erase(i)
											GameController.positionStatus[i.Position] = null
											i.queue_free()
									
									GameController.player_field_cards.append(self)
									
									get_tree().call_group("ClientInstance", "send_play_card", id, Position) # Send card and position to opponent
					else: # It's a magic
						if (
							GameController.lymph >= Cost # Enough lymph 
							and GameController.turn == "player" # Right turn
							and (Type == "Versatile" or GameController.phase == Type ) # Right phase
							and (GameController.turnType == "play" or GameController.turnType == "draw") # Right turn type
							and Location == "hand" # Right card
							and not is_returned_to_hand # Right position
							):
								if isRandom:
									GameController.lymph -= Cost
									
									GameController.player_hand.erase(self)
									GameController.UpdateHand()
									
									get_tree().call_group("GUI_Manager", "_on_Update")
									
									get_node("MagicEffect").Effect("player") # Call the magic effect ot the played card
									get_tree().call_group("OnMagic", "Effect", Team) # Call 'OnMagic' functions
									
									get_tree().call_group("ClientInstance", "send_play_magic", id) # Send card and position to opponent
									
									GameController.card_counter = 0
									
									queue_free()
								else:
									GameController.started_choosing_magic = self
									GameController.type_of_pointer = "Magic"
									
									var scene = load("res://Scenes/Game/RuntimeScenes/EnemyPointer.tscn")
									var instance = scene.instantiate()
									add_child(instance)
									
									sprite.hide()
									
									get_tree().call_group("Deactivable", "Enable", false)
						else:
							global_position = old_position
					isCardSelected = false
				else:
					if Location == "hand" and GameController.card_counter == 1: # Taking the card
						old_position = global_position
						isCardSelected = true
					if Location == "field" and not isTargetSelected and not isSearchingForEnemy and GameController.phase == "Attack" and currentLoc == "Attack" and turnInGame >= turnBlockedOnPlay and GameController.stress > GameController.player_current_stress: # Selecting the card to attack
						GameController.started_attack_card = self
						GameController.type_of_pointer = "Card"
						isSearchingForEnemy = true
						
						var scene = load("res://Scenes/Game/RuntimeScenes/EnemyPointer.tscn")
						var instance = scene.instantiate()
						add_child(instance)
						
						get_tree().call_group("Deactivable", "Enable", false)
					if Location == "field" and isTargetSelected and not isSearchingForEnemy and GameController.phase == "Attack" and currentLoc == "Attack" and turnInGame >= turnBlockedOnPlay: # Deselecting the card to attack
						GameController.CancelAttack(self)
						isTargetSelected = false
						
						GameController.player_current_stress -= 1
					if Location == "field" and not isChooseDone and not isChoosingToDefend and GameController.phase == "Defense" and currentLoc == "Defense" and turnInGame >= turnBlockedOnPlay and not isBlockedByAbility: # Choosing what to do with the card
						GameController.started_defende_card = self
						isChoosingToDefend = true
						
						var scene = load("res://Scenes/Game/RuntimeScenes/DefenseChoosing.tscn")
						var instance = scene.instantiate()
						add_child(instance)
						
						get_tree().call_group("Deactivable", "Enable", false)
						instance.global_position = global_position
					if Location == "field" and isChooseDone and not isChoosingToDefend and GameController.phase == "Defense" and currentLoc == "Defense" and turnInGame >= turnBlockedOnPlay and not isBlockedByAbility: # Cancel choose on the card
						GameController.CancelDefense(self)
						isChooseDone = false
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT and isMouseOver and isEnabled: # Click over a card with right mouse button
			if Team == "player" and GameController.turn == "player":
				if isCardSelected: # Dropping the card
					if (
						currentPos != "0" # Right position
						and GameController.positionStatus[currentPos] == null
						and GameController.turn == "player" # Right turn
						and GameController.phase == "Attack" # Right phase
						and (GameController.turnType == "play" or GameController.turnType == "draw") # Right turn type
						and Location == "field" # Right card
						and Type == "Versatile" # Right type
						):
						
						global_position = new_position
						var oldPos = Position
						GameController.positionStatus[oldPos] = null
						Position = currentPos
						GameController.positionStatus[Position] = self
						
						alreadyMoved = true
						turnInGame = turnBlockedOnPlay - 1
						
						get_tree().call_group("ClientInstance", "send_move_card", oldPos, Position) # Send old and new position to opponent
					else:
						global_position = old_position
					isCardSelected = false
				else:
					if Location == "field" and not isTargetSelected and not isSearchingForEnemy and not isChooseDone and not isChoosingToDefend and not alreadyMoved and GameController.phase == "Attack" and Type == "Versatile" and (GameController.turnType == "play" or GameController.turnType == "draw") and turnInGame >= turnBlockedOnPlay: # Move the card if it's versatile
						old_position = global_position
						isCardSelected = true
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT and isMouseOver and not inGame:
			SelectCardForDeck()


### COLLISION EVENTS ###


func _on_area_entered(area):
	if area.get_groups():
		if area.get_groups()[0] == "Positioner" and area.get_groups()[4] == "Player" and not isSearchingForEnemy and not isChoosingToDefend: # Dropping the card on a valid position
			currentPos = String(area.get_groups()[1])
			currentLoc = String(area.get_groups()[2])
			new_position = area.global_position
		
		if area.get_groups()[0] == "Pointer": # Getting selected by the pointer
			if Team == "enemy":
				GameController.selected_card_to_attack = self
				
		if area.get_groups()[0] == "Player Hand": # Returning to hand
			if Team == "player":
				is_returned_to_hand = true


func _on_area_exited(area):
	if area.get_groups():
		if area.get_groups()[0] == "Positioner" and not isSearchingForEnemy and not isChoosingToDefend and currentPos == String(area.get_groups()[1]): # Exiting by dropping the card on a valid position
			currentPos = "0"
			
		if area.get_groups()[0] == "Pointer": # Exiting by getting selected by the pointer
			if Team == "enemy":
				GameController.selected_card_to_attack = null
		
		if area.get_groups()[0] == "Player Hand": # Returning to hand
			if Team == "player":
				is_returned_to_hand = false


### OTHER FUNCTIONS ###


func get_all_children(in_node, arr:=[]):
	arr.push_back(in_node) #append an element to the end of the array
	for child in in_node.get_children():
		arr = get_all_children(child, arr)
	return arr


### GROUP RELATED ASYNC SIGNALS ###


func Enable(flag : bool): # Function called when a menu is appearing or disappearing
	isEnabled = flag


func isMagicOk(who, flag : bool): # Fuction called when a pointer is going to be deleted
	if who == self:
		if flag:
			GameController.lymph -= Cost
			
			GameController.player_hand.erase(self)
			GameController.UpdateHand()
			
			get_tree().call_group("GUI_Manager", "_on_Update")
			
			get_node("MagicEffect").Effect("player") # Call the magic effect ot the played card
			get_tree().call_group("OnMagic", "Effect", Team) # Call 'OnMagic' functions
			
			get_tree().call_group("ClientInstance", "send_play_magic", id) # Send card and position to opponent
			
			GameController.card_counter = 0
			
			queue_free()
		else:
			global_position = old_position
			isCardSelected = false
			
			sprite.show()


func isAttackOk(who, flag : bool): # Fuction called when a pointer is going to be deleted
	if who == self:
		if flag:
			isTargetSelected = true
		else:
			isTargetSelected = false
		
		isSearchingForEnemy = false


func isDefenseOk(who, what : String): # Fuction called when you choose what to do with a defender card
	if who == self:
		if what == "defende" or what == "special":
			isChooseDone = true
			hasAbilityBeenUsedThisTurn = true
			actionDuringDefense = what
		else:
			isChooseDone = false
			hasAbilityBeenUsedThisTurn = false
			actionDuringDefense = ""
		isChoosingToDefend = false


func isItYou(team : String, pos : String, target = null, atf : String = ""): # Function called to format attack and defense array (atf = array_to_fill)
	if Team == team and Position == pos:
		if not target:
			GameController.current_array_filler = self
		else:
			if atf == "pa":
				GameController.raw_player_attacks[self] = GameController.current_array_filler
			if atf == "ea":
				GameController.raw_enemy_attacks[self] = GameController.current_array_filler


func CheckForFusion(): # Function called when need to check if you can play a fusion card
	var field_cards = []
	
	for i in GameController.player_field_cards:
		if i.id in fusionid and not i.id in field_cards:
			field_cards.append(i.id)
	
	if field_cards == fusionid:
		return true
	return false


func UpdateStats(who): # Function called when card's stats change
	if who == self:
		if not isMagic and Health <= 0 and not isDead: # Check Card Health
			isDead = true
			
			if Team == "player":
				GameController.positionStatus[Position] = null
				GameController.player_field_cards.erase(self)
				
				if self.Position in GameController.player_attacks: # if he was attacking then stop it
					GameController.player_attacks.erase(self.Position)
					GameController.started_attack_card = null
					GameController.selected_card_to_attack = null
				
				GameController.player_deaths.append(id)
			else:
				GameController.enemy_field_cards.erase(self)
				
				GameController.enemy_deaths.append(id)
			
			if get_node_or_null("Common Effects/Tunnel").get_script():
				get_node("Common Effects/Tunnel").Effect() # Call 'Tunnel' function of the played card
			if get_node_or_null("Common Effects/Heritage").get_script():
				get_node("Common Effects/Heritage").Effect() # Call 'Heritage' function of the played card
			
			hide()
			
			get_tree().call_group("Revenge", "Effect", self) # Call 'Revenge' function
			
			queue_free()
		
		for i in get_all_children(self): # Update GUI
			if "Health" in i.get_groups():
				i.text = str(Health)
			if "Attack" in i.get_groups():
				i.text = str(Attack)
			if "Speed" in i.get_groups():
				i.text = str(Speed)
			if "Weight" in i.get_groups():
				i.text = str(Weight)
			if "Cost" in i.get_groups():
				i.text = str(Cost)
			if "Name" in i.get_groups():
				i.text = Name
			if "Gene" in i.get_groups():
				i.text = Gene
			if "Deviation" in i.get_groups():
				i.text = Deviation
			if "Effect" in i.get_groups():
				i.text = Effect
			if "Type" in i.get_groups():
				i.text = Type
			if "Base" in i.get_groups():
				i.text = Base


func onTurnBegin(team): # Function called on turn start (team = player / enemy)
	if Team == team:
		if Location == "field":
			turnInGame += 1
			isTargetSelected = false #attack
			isChooseDone = false #defense
			alreadyMoved = false #movement
		
		if actionDuringDefense == "defende": # Toggle the block on turn start
			isBlockedByAbility = false
			hasAbilityBeenUsedThisTurn = false


func onPhaseBegin(team): # Function called on attack phase start (team = player / enemy)
	if Team == team:
		if actionDuringDefense == "special" and not hasAbilityBeenUsedThisTurn: # Toggle the block on phase start
			isBlockedByAbility = false
		if actionDuringDefense == "special" and hasAbilityBeenUsedThisTurn: # Use special ability
			isBlockedByAbility = true
			hasAbilityBeenUsedThisTurn = false
			
			get_tree().call_group("ClientInstance", "send_special")
			GameController.UsePlayerSpecial()
			get_tree().call_group("OnSpecial", "Effect", Team)


func AttackEnemy(enemy, number): # Function called when the card has to attack another one
	enemy.Health -= Attack # Do damage
	
	get_tree().call_group("Rage", "Effect", self, enemy, number) # Call 'Rage' functions
	
	if get_node_or_null("Common Effects/Raising").get_script():
		get_node("Common Effects/Raising").Effect() # Call 'Raising' function of the played card
	if get_node_or_null("Common Effects/SweetSong").get_script():
		get_node("Common Effects/SweetSong").Effect() # Call 'Sweet Song' function of the played card
	if get_node_or_null("Common Effects/Bane").get_script():
		get_node("Common Effects/Bane").Effect() # Call 'Bane' function of the played card
	if get_node_or_null("Common Effects/SuperBane").get_script():
		get_node("Common Effects/SuperBane").Effect() # Call 'Super Bane' function of the played card
	
	get_tree().call_group("Card", "UpdateStats", enemy)


func ProtectByEnemy(enemy): # Function called when the card has to defende by another one
	enemy.Health -= Attack # Do damage
	
	get_tree().call_group("Card", "UpdateStats", enemy)


func AttackEnemyByExcess(enemy, value): # Function called when the card has to attack his original target
	enemy.Health += value # Do damage
		
	get_tree().call_group("Card", "UpdateStats", enemy)


func BoostByPos(pos, stat, value, team): # Function called when a card must change one of his main values
	if Position == pos and Team == team:
		match stat:
			"health":
				Health += value
				get_tree().call_group("OnBoost", "Effect", "health", value, self)
			"attack":
				Attack += value
				get_tree().call_group("OnBoost", "Effect", "attack", value, self)
			"speed":
				Speed += value
				get_tree().call_group("OnBoost", "Effect", "speed", value, self)
			"weight":
				Weight += value
				get_tree().call_group("OnBoost", "Effect", "weight", value, self)
			"cost":
				Cost += value
				get_tree().call_group("OnBoost", "Effect", "cost", value, self)
		UpdateStats(self)


func CreateCard(values, card_id): # Function only when the card is going to be created
	id = card_id
	
	Cost = values["cost"]
	Name = values["name"]
	Gene = values["gene"]
	Type = values["type"]
	Effect = values["effect"]
	isMagic = values["magic"]
	isRandom = values["random"]
	
	if not isMagic:
		Health = values["health"]
		Attack = values["attack"]
		Speed = values["speed"]
		Weight = values["weight"]
		Base = values["base"]
		BaseId = values["baseid"]
		Deviation = values["deviation"]
		canAttackEnemies = values["cae"]
		canAttackLeader = values["cal"]
		phase_or_turn_mutation = values["ptm"]
		mutation_id = values["mi"]
		canBeMoved = values["can_move"]
		canUseAbility = values["can_ability"]
		canBeBuffed = values["can_buf"]
		turnBlockedOnPlay = values["turn_blocked_on_play"]
		fusion = values["fusion"]
		fusionid = values["fusionid"]
	
	if values["magic"]:
		for x in self.get_children(): # attach magic script to the card
			if "MagicEffect" in x.get_groups():
				x.set_script(load("res://Scripts/Game/SpecificEffects/Effect"+str(card_id)+".gd"))
	else:
		for x in self.get_children(): # attach right script to the card
			if "Effects" in x.get_groups():
				for y in x.get_children():
					if values["effect_type"] in y.get_groups():
						if values["effect_type"] == "Phase Mutation" or values["effect_type"] == "Turn Mutation":
							y.set_script(load("res://Scripts/Game/SpecificEffects/MutationEffect.gd"))
						else:
							y.set_script(load("res://Scripts/Game/SpecificEffects/Effect"+str(card_id)+".gd"))
		
	for x in self.get_children(): # get texture reference and load card image
		if "Border" in x.get_groups():
			sprite = x
			for y in sprite.get_children():
				if "Sprite" in y.get_groups():
					y.set_texture(load("res://Resources/Images/Card"+str(card_id)+".png"))
					break
			break
	
	scale /= 1.33 # 1.35 to separete the card correctly
	
	minScale = sprite.scale
	maxScale = sprite.scale * 2.75
	
	UpdateStats(self)


### DECK CREATION VARIABLES ###


func SelectCardForDeck(): # Function called to add the card to the deck
	if times_in_deck[current_deck_ref.current_deck_pos] < card_tier and len(current_deck_ref.decks[current_deck_ref.current_deck_pos]) < 40:
		current_deck_ref.decks[current_deck_ref.current_deck_pos].append(id)
		current_deck_ref.UpdateDeck()


func RemoveFromDeck(i): # Function called when you want to remove the card from the deck
	if id == i:
		times_in_deck[current_deck_ref.current_deck_pos] -= 1

