extends Node

### Game Values ###

@export var player_health : int = 30
@export var enemy_health : int = 30
@export var lymph : int = 1
@export var stress : int = 0
@export var turn : String = ""
@export var phase : String = ""

@export var player_name = ""
@export var enemy_name = ""

var current_max_lymph : int = 0

var player_current_stress : int = 0
var enemy_current_stress : int = 0

var max_lymph : int = 10
var max_stress : int = 9

var turnType : String = "" # Action to do in current turn (play, draw, lymph, stress)

## Leaders Variables ##

var player_leader_special_effect # Special effect's script
var enemy_leader_special_effect # Special effect's script

var player_leader_ref # Player leader ref to hit it
var enemy_leader_ref # Enemy leader ref to hit it

## Setup Variables ##

var initial_number_player_cards : int = 0
var player_hand = []
var player_deck = []

var initial_number_enemy_cards : int = 0
var enemy_hand = []
var enemy_deck = []
var enemy_cards = {} # Dict of enemy cards on the field

var isScreenTaken = false # Variable to check if you can interact with buttons

## Management Variables ##

var positionStatus = { # Dictionary that contains position status
	"1" : false, "2" : false, "3" : false, "4" : false, "5" : false, "6" : false, "7" : false, "8" : false, "9" : false
}

var card_counter : int = 0 # Variable that check how many card you are tryng to select

## Attack Variables ##

var started_attack_card # the card that is attacking
var selected_card_to_attack # the card that is selected by the pointer

var player_attacks = {} # Dict with who is attacing who (attacker_pos : defender_pos)
var enemy_attacks = {} # Dict with who is attacing who (attacker_pos : defender_pos)
var raw_player_attacks = {} # Dict with who is attacing who (attacker_pos : defender_pos)
var raw_enemy_attacks = {} # Dict with who is attacing who (attacker_pos : defender_pos)

var current_array_filler = null # Variable used to format the attack and defense array / dict

## Defende Variables ##

var started_defende_card # the card that is choosing to defende or not

var player_defends = [] # List with who is defending
var enemy_defends = [] # List with who is defending
var raw_player_defends = [] # List with who is defending
var raw_enemy_defends = [] # List with who is defending

### MAIN EVENTS ###


func _ready():
	print("Game Started!")
	
	player_name = Data.nickname
	
	player_deck = get_tree().get_first_node_in_group("Data").deck
	initial_number_player_cards = get_tree().get_first_node_in_group("Data").initial_number_player_cards
	initial_number_enemy_cards = get_tree().get_first_node_in_group("Data").initial_number_enemy_cards
	enemy_deck = get_tree().get_first_node_in_group("Data").enemy_back_deck
	
	for i in initial_number_player_cards:
		add_child(player_deck[i])
		player_hand.append(player_deck[i])
		player_deck.remove_at(i)
	
	for i in initial_number_enemy_cards:
		enemy_hand.append(enemy_deck[-1])
		add_child(enemy_hand[-1])
		enemy_deck.remove_at(enemy_deck.size() - 1)
	
	UpdateHand()
	UpdateEnemyHand()
	
	## SETUP ##
	
	current_max_lymph = lymph
	
	get_tree().get_first_node_in_group("Player_Name").text = player_name
	get_tree().get_first_node_in_group("Enemy_Name").text = enemy_name


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
		
		get_tree().call_group("ClientInstance", "send_defense", player_defends)
	
	elif turn == "player" and phase == "attack":
		turn = "enemy"
		phase = "defense"
		get_tree().call_group("Card", "onTurnBegin", "enemy")
		
		lymph = current_max_lymph
	
	elif turn == "enemy" and phase == "defense":
		phase = "attack"
		get_tree().call_group("Card", "onPhaseBegin", "enemy")
		
		get_tree().call_group("ClientInstance", "send_attack", player_attacks)
	
	get_tree().call_group("GUI_Manager", "_on_Update")


func InitialSetupForGameStart(nickname, canStart):
	enemy_name = nickname
	# set skin and leader ability
	
	if canStart == "true":
		turn = "player"
		get_tree().get_first_node_in_group("TurnManager").visible = true
	else:
		turn = "enemy"
	
	get_tree().call_group("Leader", "setGlobalId")
	
	print("Setup Finished !!")


func SetLeaders(team, leader_id, ref): # Save leader special powers
	if team == "player":
		var scene1 = load("res://Scenes/Game/LeaderSpecials/Special"+ str(leader_id) +".tscn")
		player_leader_special_effect = scene1.instantiate()
		add_child(player_leader_special_effect)
		player_leader_ref = ref
	else:
		var scene2 = load("res://Scenes/Game/LeaderSpecials/Special"+ str(leader_id) +".tscn")
		enemy_leader_special_effect = scene2.instantiate()
		add_child(enemy_leader_special_effect)
		enemy_leader_ref = ref


### TURN MANAGEMEN FUNCTIONS ###


func PlayCard():
	if len(player_hand) > 0:
		turnType = "play"
		
		get_tree().call_group("ClientInstance", "send_turn_choice", turnType) # Send turn type to opponent


func DrawCard():
	if len(player_deck) > 0 and len(player_hand) < 10:
		turnType = "draw"
		DrawOneCard()
		
		get_tree().call_group("ClientInstance", "send_turn_choice", turnType) # Send turn type to opponent


func AddLymph():
	if lymph < max_lymph:
		turnType = "lymph"
		lymph += 1
		current_max_lymph += 1
		
		get_tree().call_group("ClientInstance", "send_turn_choice", turnType) # Send turn type to opponent


func AddStress():
	if stress < max_stress:
		turnType = "stress"
		stress += 1
		
		get_tree().call_group("ClientInstance", "send_turn_choice", turnType) # Send turn type to opponent


### OTHER FUNCTIONS ###


# Deck #

func DrawOneCard():
	if len(player_deck) > 0 and len(player_hand) < 10:
		player_hand.append(player_deck[-1])
		add_child(player_deck[-1])
		player_deck.remove_at(player_deck.size() - 1)
		
		UpdateHand()

func UpdateHand():
	var i : int = 0
	
	for item in player_hand:
		i += 1
		
		if len(player_hand) % 2 == 0:
			@warning_ignore("integer_division")
			item.global_position = Vector2((540 - ((len(player_hand) / 2) * 55)) + (57.65*i), 510)
		else:
			@warning_ignore("integer_division")
			item.global_position = Vector2((520 - (((len(player_hand) - 1) / 2) * 55)) + (57.65*i), 510)

func ShuffleDeck():
	player_deck.shuffle()

# Attack and Defense #

func AttackResult(flag : bool): # Function called when an attack is confirmed or not setted
	if flag:
		player_attacks[started_attack_card.Position] = selected_card_to_attack.Position
		started_attack_card = null
		selected_card_to_attack = null
	else:
		started_attack_card = null
		selected_card_to_attack = null

func CancelAttack(who): # Function called when an attack is cancelled
	player_attacks.erase(who.Position)
	started_attack_card = null
	selected_card_to_attack = null

func DefenseResult(flag : bool): # Function called when a defense is confirmed or not setted
	if flag:
		player_defends.append(started_defende_card.Position)
		started_defende_card = null
	else:
		started_defende_card = null

func CancelDefense(who): # Function called when a defense is cancelled
	player_defends.erase(who.Position)
	started_defende_card = null

func UsePlayerSpecial(): #Function called when player use a special
	player_leader_special_effect.UsePlayerEffect()

func UseEnemySpecial(): #Function called when enemy use a special
	enemy_leader_special_effect.UseEnemyEffect()

func ManagePlayerDefense(): # Function that contains player defense system
	if raw_enemy_attacks.size() > 0:
		var attackers = [] # attacker array from quicker to slower
		var targets = [] # targets array ordered like quickers
		var defenders = [] # attacker array from quicker to slower
		
		while raw_enemy_attacks.size() > 0: # order the attacker from quicker to slower
			var first_obj = true
			
			for i in raw_enemy_attacks: #iterate all the attackers to select the quicker
				if first_obj:
					attackers.append(i)
					first_obj = false
				elif i.Speed <= attackers[-1].Speed: #if it's slower than the first select him
					if i.Speed == attackers[-1].Speed:
						if i.Weight >= attackers[-1].Weight: #if it's less heavy than the first select him
							if i.Weight == attackers[-1].Weight:
								if i.Attack <= attackers[-1].Attack: #if it's has more attack than the first select him
									if i.Attack == attackers[-1].Attack:
										if i.Health <= attackers[-1].Health: #if it's has more health than the first select him
											if i.Health == attackers[-1].Health:
												if i.Cost < attackers[-1].Cost: #if it's cheaper than the first select him
													attackers[-1] = i
										else:
											attackers[-1] = i
								else:
									attackers[-1] = i
						else:
							attackers[-1] = i
				else:
					attackers[-1] = i
			
			targets.append(raw_enemy_attacks[attackers[-1]]) #remember his target
			raw_enemy_attacks.erase(attackers[-1]) #remove the slowest (it will be the last attacker)
		
		while raw_player_defends.size() > 0: # order the attacker from quicker to slower
			var first_obj = true
			
			for i in raw_player_defends: #iterate all the defenders to select the quicker
				if first_obj:
					defenders.append(i)
					first_obj = false
				elif i.Speed <= defenders[-1].Speed: #if it's slower than the first select him
					if i.Speed == defenders[-1].Speed:
						if i.Weight >= defenders[-1].Weight: #if it's less heavy than the first select him
							if i.Weight == defenders[-1].Weight:
								if i.Attack <= defenders[-1].Attack: #if it's has more attack than the first select him
									if i.Attack == defenders[-1].Attack:
										if i.Health <= defenders[-1].Health: #if it's has more health than the first select him
											if i.Health == defenders[-1].Health:
												if i.Cost < defenders[-1].Cost: #if it's cheaper than the first select him
													defenders[-1] = i
										else:
											defenders[-1] = i
								else:
									defenders[-1] = i
						else:
							defenders[-1] = i
				else:
					defenders[-1] = i
			
			raw_player_defends.erase(defenders[-1]) #remove the slowest (it will be the last attacker)
		
		if attackers.size() > defenders.size(): # if there are more attackers than defenders
			var a = 0
			
			while attackers.size() > defenders.size(): # remove all extra defender
				Fight(attackers[a], targets[a], false)
				
				attackers.remove_at(0)
				targets.remove_at(0)
			
			while a < len(attackers): #attackers attack the desired target
				Fight(attackers[a], defenders[a], true)
				a += 1
		elif attackers.size() < defenders.size(): # if there are less attackers than defenders
			var b = 0
			
			while attackers.size() < defenders.size(): # remove all extra defender
				defenders.remove_at(defenders.size() - 1)
			
			while b < len(attackers): #attackers attack the desired target
				Fight(attackers[b], defenders[b], true)
				b += 1
		else: # same number of attacker and defenders
			var c = 0
			
			while c < len(attackers): #attackers attack the desired target
				Fight(attackers[c], defenders[c], true)
				c += 1

func ManageEnemyDefense(): # Function that contains enemy defense system
	if raw_player_attacks.size() > 0:
		var attackers = [] # attacker array from quicker to slower
		var targets = [] # targets array ordered like quickers
		var defenders = [] # attacker array from quicker to slower
		
		while raw_player_attacks.size() > 0: # order the attacker from quicker to slower
			var first_obj = true
			
			for i in raw_player_attacks: #iterate all the attackers to select the quicker
				if first_obj:
					attackers.append(i)
					first_obj = false
				elif i.Speed <= attackers[-1].Speed: #if it's slower than the first select him
					if i.Speed == attackers[-1].Speed:
						if i.Weight >= attackers[-1].Weight: #if it's less heavy than the first select him
							if i.Weight == attackers[-1].Weight:
								if i.Attack <= attackers[-1].Attack: #if it's has more attack than the first select him
									if i.Attack == attackers[-1].Attack:
										if i.Health <= attackers[-1].Health: #if it's has more health than the first select him
											if i.Health == attackers[-1].Health:
												if i.Cost < attackers[-1].Cost: #if it's cheaper than the first select him
													attackers[-1] = i
										else:
											attackers[-1] = i
								else:
									attackers[-1] = i
						else:
							attackers[-1] = i
				else:
					attackers[-1] = i
			
			targets.append(raw_player_attacks[attackers[-1]]) #remember his target
			raw_player_attacks.erase(attackers[-1]) #remove the slowest (it will be the last attacker)
		
		while raw_enemy_defends.size() > 0: # order the attacker from quicker to slower
			var first_obj = true
			
			for i in raw_enemy_defends: #iterate all the defenders to select the quicker
				if first_obj:
					defenders.append(i)
					first_obj = false
				elif i.Speed <= defenders[-1].Speed: #if it's slower than the first select him
					if i.Speed == defenders[-1].Speed:
						if i.Weight >= defenders[-1].Weight: #if it's less heavy than the first select him
							if i.Weight == defenders[-1].Weight:
								if i.Attack <= defenders[-1].Attack: #if it's has more attack than the first select him
									if i.Attack == defenders[-1].Attack:
										if i.Health <= defenders[-1].Health: #if it's has more health than the first select him
											if i.Health == defenders[-1].Health:
												if i.Cost < defenders[-1].Cost: #if it's cheaper than the first select him
													defenders[-1] = i
										else:
											defenders[-1] = i
								else:
									defenders[-1] = i
						else:
							defenders[-1] = i
				else:
					defenders[-1] = i
			
			raw_enemy_defends.erase(defenders[-1]) #remove the slowest (it will be the last attacker)
		
		if attackers.size() > defenders.size(): # if there are more attackers than defenders
			var a = 0
			
			while attackers.size() > defenders.size(): # remove all extra defender
				Fight(attackers[a], targets[a], false)
				
				attackers.remove_at(0)
				targets.remove_at(0)
			
			while a < len(attackers): #attackers attack the desired target
				Fight(attackers[a], defenders[a], true)
				a += 1
		elif attackers.size() < defenders.size(): # if there are less attackers than defenders
			var b = 0
			
			while attackers.size() < defenders.size(): # remove all extra defender
				defenders.remove_at(defenders.size() - 1)
			
			while b < len(attackers): #attackers attack the desired target
				Fight(attackers[b], defenders[b], true)
				b += 1
		else: # same number of attacker and defenders
			var c = 0
			
			while c < len(attackers): #attackers attack the desired target
				Fight(attackers[c], defenders[c], true)
				c += 1

func FormatOnDefende(): # Function called to make previous function work properly
	for c in enemy_attacks:
		if enemy_attacks[c] == "10":
			get_tree().call_group("Card", "isItYou", "enemy", c)
			raw_enemy_attacks[current_array_filler] = player_leader_ref
			current_array_filler = null
		else:
			get_tree().call_group("Card", "isItYou", "player", enemy_attacks[c])
			get_tree().call_group("Card", "isItYou", "enemy", c, current_array_filler, "ea")
			current_array_filler = null
	
	for b in player_defends:
		get_tree().call_group("Card", "isItYou", "player", b)
		raw_player_defends.append(current_array_filler)
		current_array_filler = null

func FormatOnAttack(): # Function called to make previous function work properly
	for d in enemy_defends:
		get_tree().call_group("Card", "isItYou", "enemy", d)
		raw_enemy_defends.append(current_array_filler)
		current_array_filler = null
	
	for a in player_attacks:
		if player_attacks[a] == "10":
			get_tree().call_group("Card", "isItYou", "player", a)
			raw_player_attacks[current_array_filler] = enemy_leader_ref
			current_array_filler = null
		else:
			get_tree().call_group("Card", "isItYou", "enemy", player_attacks[a])
			get_tree().call_group("Card", "isItYou", "player", a, current_array_filler, "pa")
			current_array_filler = null

func Fight(attacker, defender, canDefend : bool):
	attacker.AttackEnemy(defender) #attacker attack the defender
	
	if canDefend:
		print("Fight --> " + attacker.Name + "(" + attacker.Team + ") vs " + defender.Name + "(" + defender.Team + ") (protecting himself)")
		defender.ProtectByEnemy(attacker) #defender protect himself only if the proprietary decided to defend
	else:
		print("Fight --> " + attacker.Name + "(" + attacker.Team + ") vs " + defender.Name + "(" + defender.Team + ") (without defending himself)")
	
	get_tree().call_group("Leader", "_on_Update")
	get_tree().call_group("GUI_Manager", "_on_Update")

# Management #

func Enable(flag : bool): # Function called when a menu is appearing or disappearing
	isScreenTaken = not flag

# Game Result #

func GameEnds(looser): # Function called when someone dies (looser = who died)
	if looser == "player":
		print(str(player_name) + " died!")
	if looser == "enemy":
		print(str(enemy_name) + " died!")


### OPPONENT FIELD MANAGEMENT FUNCTIONS ###


# Prepare Game Session #

func UpdateEnemyHand():
	var i : int = 0
	
	for item in enemy_hand:
		i += 1
		
		if len(enemy_hand) % 2 == 0:
			@warning_ignore("integer_division")
			item.global_position = Vector2((540 - ((len(enemy_hand) / 2) * 48)) + (46*i), 20)
		else:
			@warning_ignore("integer_division")
			item.global_position = Vector2((520 - (((len(enemy_hand) - 1) / 2) * 48)) + (46*i), 20)

# Turn Selection #

func DrawEnemyCard():
	if len(enemy_deck) > 0 and len(enemy_hand) < 10:
		enemy_hand.append(enemy_deck[-1])
		add_child(enemy_hand[-1])
		enemy_deck.remove_at(enemy_deck.size() - 1)
		
		UpdateEnemyHand()

# During Opponent Turn #

func PlayEnemyCard(id, pos, stats):
	enemy_hand[-1].queue_free()
	enemy_hand.remove_at(enemy_hand.size() - 1) # Remove card from enemy hand
	
	var scene = load("res://Scenes/Game/Cards/Card"+str(int(id))+".tscn") # Load card resources
	var instance = scene.instantiate() # Instantiate card resources
	enemy_cards[pos] = instance # Save card instance
	enemy_cards[pos].Team = "enemy" # Set team for new card
	enemy_cards[pos].Position = pos # Set position for new card
	enemy_cards[pos].Location = "field" # Set location for new card
	
	add_child(enemy_cards[pos]) # Create card
	
	var positioner_pos = get_tree().get_first_node_in_group("EP"+str(pos)) # Get the right position
	enemy_cards[pos].global_position = positioner_pos.global_position # Move card to the right position
	
	if stats != []: # Stats different to default
		enemy_cards[pos].Health = stats[0]
		enemy_cards[pos].Attack = stats[1]
		enemy_cards[pos].Speed = stats[2]
		enemy_cards[pos].Weight = stats[3]
	
	lymph -= enemy_cards[pos].Cost # Update lymph used by enemy
	
	UpdateEnemyHand()
	
	get_tree().call_group("GUI_Manager", "_on_Update")

func MoveEnemyCard(old_pos, new_pos):
	var positioner_pos = get_tree().get_first_node_in_group("EP"+str(new_pos))
	enemy_cards[old_pos].global_position = positioner_pos.global_position # Swap cards position
	enemy_cards[new_pos] = enemy_cards[old_pos] # Add new position to card dict
	enemy_cards.erase(old_pos) # Remove old position from card dict
	
	get_tree().call_group("GUI_Manager", "_on_Update")

