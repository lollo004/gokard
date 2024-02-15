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
var max_stress : int = 5
var over_stress : int = 0

var turnType : String = "" # Action to do in current turn (play, draw, lymph, stress)

@export var error_label : Label

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

## Management Variables ##

var positionStatus = { # Dictionary that contains position status
	"1" : null, "2" : null, "3" : null, "4" : null, "5" : null, "6" : null, "7" : null, "8" : null, "9" : null
}

var card_counter : int = 0 # Variable that check how many card you are tryng to select

var player_field_cards = [] # list of all player cards on the field
var enemy_field_cards = [] # list of all enemy cards on the field

var player_deaths = [] # list of all player dead card's ids
var enemy_deaths = [] # list of all enemy dead card's ids

## Attack Variables ##

var started_attack_card # the card that is attacking
var selected_card_to_attack # the card that is selected by the pointer during attack

var player_attacks = {} # Dict with who is attacing who (attacker_pos : defender_pos)
var enemy_attacks = {} # Dict with who is attacing who (attacker_pos : defender_pos)
var raw_player_attacks = {} # Dict with who is attacing who (attacker_pos : defender_pos)
var raw_enemy_attacks = {} # Dict with who is attacing who (attacker_pos : defender_pos)

var current_array_filler = null # Variable remember who attack who and comunicate between Card.gd and GameController.gd

## Defende Variables ##

var started_defende_card # the card that is choosing to defende or not

var player_defends = [] # List with who is defending
var enemy_defends = [] # List with who is defending
var raw_player_defends = [] # List with who is defending
var raw_enemy_defends = [] # List with who is defending

## Magic Variables ##

var started_choosing_magic # the magic that is selecting
var selected_card_to_target_with_magic # the card that is selected by the pointer during magics
var type_of_pointer = "" # type of action for the pointer (Card / Magic)

## Timers ##

var timer = []
var current_showed_card_ref = []

## Animation Variables ##

var isScreenTaken = false # Variable to check if you can interact with buttons


### MAIN EVENTS ###


func _ready():
	print("Game Started!")
	
	player_name = Data.nickname
	
	player_deck = get_tree().get_first_node_in_group("Data").deck
	initial_number_player_cards = get_tree().get_first_node_in_group("Data").initial_number_player_cards
	initial_number_enemy_cards = get_tree().get_first_node_in_group("Data").initial_number_enemy_cards
	enemy_deck = get_tree().get_first_node_in_group("Data").enemy_back_deck
	
	ShuffleDeck()
	
	for i in initial_number_player_cards:
		add_child(player_deck[i])
		player_hand.append(player_deck[i])
		player_hand[-1].Location = "hand"
		player_deck.remove_at(i)
	
	for i in initial_number_enemy_cards:
		enemy_hand.append(enemy_deck[-1])
		add_child(enemy_hand[-1])
		enemy_deck.remove_at(enemy_deck.size() - 1)
	
	UpdateHand()
	UpdateEnemyHand()
	
	## SETUP ##
	
	current_max_lymph = lymph


### PUBLIC FUNCTION ###


func TurnButtonPressed():
	if turn == "enemy" and phase == "Attack":
		turn = "player"
		phase = "Defense"
		get_tree().call_group("onTurnBegin", "Effect", "player")
		get_tree().call_group("Card", "onTurnBegin", "player")
		get_tree().call_group("Phase Mutation", "Effect")
		get_tree().call_group("Turn Mutation", "Effect")
		
		get_tree().get_first_node_in_group("TurnManager").visible = true
		get_tree().call_group("Deactivable", "Enable", false)
		
		lymph = current_max_lymph
		player_current_stress = 0
		stress -= over_stress
		over_stress = 0
		
		DrawOneCard()
	
	elif turn == "player" and phase == "Defense":
		phase = "Attack"
		get_tree().call_group("onPhaseBegin", "Effect", "player")
		get_tree().call_group("Card", "onPhaseBegin", "player")
		get_tree().call_group("Phase Mutation", "Effect")
		
		get_tree().call_group("ClientInstance", "send_defense", player_defends)
		
		for i in player_field_cards:
			i.shadow.set_texture(load("res://Resources/CardCreation/CardGlow.png"))
	
	elif turn == "player" and phase == "Attack":
		turn = "enemy"
		phase = "Defense"
		get_tree().call_group("onTurnBegin", "Effect", "enemy")
		get_tree().call_group("Card", "onTurnBegin", "enemy")
		get_tree().call_group("Phase Mutation", "Effect")
		get_tree().call_group("Turn Mutation", "Effect")
		
		lymph = current_max_lymph
		stress -= over_stress
		over_stress = 0
		
		DrawEnemyCard()
	
	elif turn == "enemy" and phase == "Defense":
		phase = "Attack"
		get_tree().call_group("onPhaseBegin", "Effect", "enemy")
		get_tree().call_group("Card", "onPhaseBegin", "enemy")
		get_tree().call_group("Phase Mutation", "Effect")
		
		get_tree().call_group("ClientInstance", "send_attack", player_attacks)
		
		for i in player_field_cards:
			i.shadow.set_texture(load("res://Resources/CardCreation/CardGlow.png"))
	
	get_tree().call_group("GUI_Manager", "_on_Update")


func InitialSetupForGameStart(nickname, canStart, rnd_seed, leader_id, leader_pos):
	enemy_name = nickname
	
	# Set player leader
	player_leader_special_effect = load("res://Scenes/Game/LeaderSpecials/Special"+ str(Data.leader_id) +".tscn").instantiate()
	add_child(player_leader_special_effect)
	
	var pl = load("res://Scenes/Game/Cards/Card.tscn") # Load card resources
	player_leader_ref = pl.instantiate() # Instantiate card resources
	player_leader_ref.global_position = get_tree().get_first_node_in_group("PP"+Data.leader_pos).global_position - Vector2(0,20)
	player_leader_ref.Location = "field"
	player_leader_ref.Position = leader_pos
	positionStatus[Data.leader_pos] = player_leader_ref
	player_leader_ref.isLeader = true
	player_leader_ref.Team = "player"
	player_leader_ref.CreateCard(CardsList.getCardInfo(int(Data.leader_id), true), int(Data.leader_id), true) # Getting starter values
	player_leader_ref.turnBlockedOnPlay = 0
	if int(Data.leader_pos) % 2 == 0:
		player_leader_ref.currentLoc.append("Defense")
	else:
		player_leader_ref.currentLoc.append("Attack")
	player_leader_ref.Name = player_name
	
	player_leader_ref.shadow.offset.y = -100
	player_leader_ref.shadow.scale = Vector2(4.1,2.15)
	player_leader_ref.shadow.show()
	player_leader_ref.shadow.process_mode = Node.PROCESS_MODE_INHERIT
	player_leader_ref.ShiftBack()
	player_leader_ref.SetOnMini()
	
	add_child(player_leader_ref) # Create card
	player_leader_ref.UpdateStats(player_leader_ref)
	
	player_field_cards.append(player_leader_ref)
	
	# Set enemy leader
	enemy_leader_special_effect = load("res://Scenes/Game/LeaderSpecials/Special"+ str(leader_id) +".tscn").instantiate()
	add_child(enemy_leader_special_effect)
	
	var el = load("res://Scenes/Game/Cards/Card.tscn") # Load card resources
	enemy_leader_ref = el.instantiate() # Instantiate card resources
	enemy_leader_ref.global_position = get_tree().get_first_node_in_group("EP"+leader_pos).global_position - Vector2(0,20)
	enemy_leader_ref.Location = "field"
	enemy_leader_ref.Position = leader_pos
	enemy_leader_ref.isLeader = true
	enemy_leader_ref.Team = "enemy"
	enemy_leader_ref.CreateCard(CardsList.getCardInfo(int(leader_id), true), int(leader_id), true) # Getting starter values
	enemy_leader_ref.turnBlockedOnPlay = 0
	if int(leader_pos) % 2 == 0:
		enemy_leader_ref.currentLoc.append("Defense")
	else:
		enemy_leader_ref.currentLoc.append("Attack")
	enemy_leader_ref.Name = enemy_name
	
	enemy_leader_ref.ShiftBack()
	enemy_leader_ref.SetOnMini()
	
	add_child(enemy_leader_ref) # Create card
	enemy_leader_ref.UpdateStats(enemy_leader_ref)
	
	enemy_field_cards.append(enemy_leader_ref)
	enemy_cards[leader_pos] = enemy_leader_ref
	
	get_tree().call_group("GUI_Manager", "_on_Update")
	
	# Seed setup and start game
	Data.RANDOM.set_seed(hash(rnd_seed)) # randomize seed according to other client
	#print("\n"+str(rnd_seed)+" "+str(hash(rnd_seed))+"\n")
	
	if canStart == "true":
		turn = "player"
		isScreenTaken = true
		get_tree().get_first_node_in_group("TurnManager").visible = true
	else:
		turn = "enemy"
		get_tree().get_first_node_in_group("Turn").text = "Opponent \n Turn"
	
	print("Setup Finished !!")


func SetLeaders(team, leader_id, ref): # Save leader special powers
	if team == "player":
		player_leader_special_effect = load("res://Scenes/Game/LeaderSpecials/Special"+ str(leader_id) +".tscn").instantiate()
		add_child(player_leader_special_effect)
		player_leader_ref = ref
		
		player_leader_ref.get_child(0).set_texture(load("res://Resources/Leaders/Leader"+ str(leader_id) +".png"))
	else:
		enemy_leader_special_effect = load("res://Scenes/Game/LeaderSpecials/Special"+ str(leader_id) +".tscn").instantiate()
		add_child(enemy_leader_special_effect)
		enemy_leader_ref = ref
		
		enemy_leader_ref.get_child(0).set_texture(load("res://Resources/Leaders/Leader"+ str(leader_id) +".png"))


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
		add_child(player_hand[-1])
		player_deck.remove_at(player_deck.size() - 1)
		
		player_hand[-1].Location = "hand"
		player_hand[-1].Team = "player"
		if not get_tree().get_first_node_in_group("TurnManager").visible:
			player_hand[-1].isEnabled = true
		
		UpdateHand()
		
		get_tree().call_group("OnDraw", "Effect", "player") # Call 'OnDraw' functions
		
		return player_hand[-1]
	return null

func UpdateHand():
	var i : int = 0
	
	for item in player_hand:
		i += 1
		
		if len(player_hand) % 2 == 0:
			item.global_position = Vector2((470.0 - ((len(player_hand) / 2.0) * 55.0)) + (57.65*i), 510.0)
		else:
			item.global_position = Vector2((450.0 - (((len(player_hand) - 1.0) / 2.0) * 55.0)) + (57.65*i), 510.0)

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

func UsePlayerSpecial(pos): #Function called when player use a special
	player_leader_special_effect.UsePlayerEffect(pos)

func UseEnemySpecial(pos): #Function called when enemy use a special
	enemy_leader_special_effect.UseEnemyEffect(pos)

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
			var x = 0
			
			while attackers.size() > defenders.size(): #attackers attack the desired target
				await Fight(attackers[a], targets[a], false, x, null)
				
				attackers.remove_at(0)
				targets.remove_at(0)
				
				x += 1
			
			while a < len(attackers): # remove all extra attacker
				await Fight(attackers[a], defenders[a], true, x, targets[a])
				a += 1
				x += 1
		elif attackers.size() < defenders.size(): # if there are less attackers than defenders
			var b = 0
			var x = 0
			
			while attackers.size() < defenders.size(): # remove all extra defender
				defenders.remove_at(defenders.size() - 1)
			
			while b < len(attackers): #attackers attack the desired target
				await Fight(attackers[b], defenders[b], true, x, targets[b])
				b += 1
				
				x += 1
		else: # same number of attacker and defenders
			var c = 0
			var x = 0
			
			while c < len(attackers): #attackers attack the desired target
				await Fight(attackers[c], defenders[c], true, x, targets[c])
				c += 1
				
				x += 1

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
			var x = 0
			
			while attackers.size() > defenders.size(): #attackers attack the desired target
				await Fight(attackers[a], targets[a], false, x, null)
				
				attackers.remove_at(0)
				targets.remove_at(0)
				
				x += 1
			
			while a < len(attackers): # remove all extra attacker
				await Fight(attackers[a], defenders[a], true, x, targets[a])
				a += 1
				
				x += 1
		elif attackers.size() < defenders.size(): # if there are less attackers than defenders
			var b = 0
			var x = 0
			
			while attackers.size() < defenders.size(): # remove all extra defender
				defenders.remove_at(defenders.size() - 1)
			
			while b < len(attackers): #attackers attack the defenders
				await Fight(attackers[b], defenders[b], true, x, targets[b])
				b += 1
				
				x += 1
		else: # same number of attacker and defenders
			var c = 0
			var x = 0
			
			while c < len(attackers): #attackers attack the desired target
				await Fight(attackers[c], defenders[c], true, x, targets[c])
				c += 1
				
				x += 1

func FormatOnDefende(): # Function called to make previous functions work properly
	for c in enemy_attacks:
		if enemy_attacks[c] == "10":#leader
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
	
	for i in player_defends:
		get_tree().get_first_node_in_group("PP"+i).show()
		get_tree().get_first_node_in_group("PP"+i).get_child(2).hide()
		get_tree().get_first_node_in_group("PP"+i).get_child(4).show()
	for i in enemy_attacks:
		get_tree().get_first_node_in_group("EP"+i).show()
		get_tree().get_first_node_in_group("EP"+i).get_child(2).hide()
		get_tree().get_first_node_in_group("EP"+i).get_child(3).show()
	
	await get_tree().create_timer(1.5).timeout
	
	for i in player_defends:
		get_tree().get_first_node_in_group("PP"+i).hide()
		get_tree().get_first_node_in_group("PP"+i).get_child(2).show()
		get_tree().get_first_node_in_group("PP"+i).get_child(4).hide()
	for i in enemy_attacks:
		get_tree().get_first_node_in_group("EP"+i).hide()
		get_tree().get_first_node_in_group("EP"+i).get_child(2).show()
		get_tree().get_first_node_in_group("EP"+i).get_child(3).hide()

func FormatOnAttack(): # Function called to make previous functions work properly
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
	
	for i in player_attacks:
		get_tree().get_first_node_in_group("PP"+i).show()
		get_tree().get_first_node_in_group("PP"+i).get_child(2).hide()
		get_tree().get_first_node_in_group("PP"+i).get_child(3).show()
	for i in enemy_defends:
		get_tree().get_first_node_in_group("EP"+i).show()
		get_tree().get_first_node_in_group("EP"+i).get_child(2).hide()
		get_tree().get_first_node_in_group("EP"+i).get_child(4).show()
	
	await get_tree().create_timer(1.5).timeout
	
	for i in player_attacks:
		get_tree().get_first_node_in_group("PP"+i).hide()
		get_tree().get_first_node_in_group("PP"+i).get_child(2).show()
		get_tree().get_first_node_in_group("PP"+i).get_child(3).hide()
	for i in enemy_defends:
		get_tree().get_first_node_in_group("EP"+i).hide()
		get_tree().get_first_node_in_group("EP"+i).get_child(2).show()
		get_tree().get_first_node_in_group("EP"+i).get_child(4).hide()

func Fight(attacker, defender, canDefend : bool, n, target):
	if Data.isInstanceValid(attacker) and Data.isInstanceValid(defender):
		# Target lock animation
		var T_GUI = load("res://Scenes/Game/RuntimeScenes/TargetAnimation.tscn").instantiate()
		add_child(T_GUI)
		T_GUI.a = attacker
		T_GUI.b = defender
		T_GUI.Start()
		
		if canDefend:
			print("Fight --> " + attacker.Name + "(" + attacker.Team + ") vs " + defender.Name + "(" + defender.Team + ") (protecting himself)")
			
			# Card defense animation
			var S_GUI = load("res://Scenes/Game/RuntimeScenes/ShieldAnimation.tscn").instantiate()
			add_child(S_GUI)
			S_GUI.global_position = defender.global_position
			S_GUI.Start()
			
			await get_tree().create_timer(1.5).timeout
			T_GUI.queue_free()
			S_GUI.queue_free()
			
			attacker.AttackEnemy(defender, n) #attacker attack the defender
		
			if defender.Health < 0:
				attacker.AttackEnemyByExcess(target, defender.Health) #attacker attack his first target
			
			defender.ProtectByEnemy(attacker) #defender protect himself only if the proprietary decided to defend
		else:
			print("Fight --> " + attacker.Name + "(" + attacker.Team + ") vs " + defender.Name + "(" + defender.Team + ") (without defending himself)")
			
			await get_tree().create_timer(1.5).timeout
			T_GUI.queue_free()
			
			attacker.AttackEnemy(defender, n) #attacker attack the defender
		
		get_tree().call_group("Leader", "_on_Update")
		get_tree().call_group("GUI_Manager", "_on_Update")

# Management #

func Enable(flag : bool): # Function called when a menu is appearing or disappearing
	isScreenTaken = not flag

func UserError(t):
	error_label.text = t
	error_label.modulate.a = 0
	
	var tween = get_tree().create_tween() # show and then hide the error message
	tween.tween_property(error_label, "modulate", Color(1,0,0,1), 1.5) # visible red
	tween.tween_property(error_label, "modulate", Color(1,0,0,0), 2.5) # transparent red

# Game Result #

func GameEnds(looser): # Function called when someone dies (looser = who died)
	if looser == "player":
		print(str(player_name) + " died!")
	if looser == "enemy":
		print(str(enemy_name) + " died!")
	
	await get_tree().create_timer(5.0).timeout
	get_tree().change_scene_to_file("Scenes/Lobby/MainMenu.tscn")


### OPPONENT FIELD MANAGEMENT FUNCTIONS ###


# Prepare Game Session #

func UpdateEnemyHand():
	var i : int = 0
	
	for item in enemy_hand:
		i += 1
		
		if len(enemy_hand) % 2 == 0:
			item.global_position = Vector2((470.0 - ((len(enemy_hand) / 2.0) * 48.0)) + (44.0*i), 20.0)
		else:
			item.global_position = Vector2((450.0 - (((len(enemy_hand) - 1.0) / 2.0) * 48.0)) + (44.0*i), 20.0)

# Turn Selection #

func DrawEnemyCard():
	if len(enemy_deck) > 0 and len(enemy_hand) < 10:
		enemy_hand.append(enemy_deck[-1])
		add_child(enemy_hand[-1])
		enemy_deck.remove_at(enemy_deck.size() - 1)
		
		UpdateEnemyHand()
		
		get_tree().call_group("OnDraw", "Effect", "enemy") # Call 'OnDraw' functions

# During Opponent Turn #

func PlayEnemyCard(id, pos, stats):
	enemy_hand[-1].queue_free()
	enemy_hand.remove_at(enemy_hand.size() - 1) # Remove card from enemy hand
	
	var scene = load("res://Scenes/Game/Cards/Card.tscn") # Load card resources
	var instance = scene.instantiate() # Instantiate card resources
	enemy_cards[pos] = instance # Save card instance
	enemy_cards[pos].CreateCard(CardsList.getCardInfo(int(id)), int(id)) # Getting starter values
	enemy_cards[pos].Team = "enemy" # Set team for new card
	enemy_cards[pos].Position = pos # Set position for new card
	enemy_cards[pos].Location = "field" # Set location for new card
	
	var positioner_pos = get_tree().get_first_node_in_group("EP"+str(pos)) # Get the right position
	enemy_cards[pos].global_position = positioner_pos.global_position - Vector2(0,20) # Move card to the right position
	
	enemy_cards[pos].SetOnMini()
	enemy_cards[pos].ShiftBack()
	
	if stats != []: # Stats different to default
		enemy_cards[pos].Health = stats[0]
		enemy_cards[pos].Attack = stats[1]
		enemy_cards[pos].Speed = stats[2]
		enemy_cards[pos].Weight = stats[3]
		enemy_cards[pos].Cost = stats[4]
		enemy_cards[pos].stats_has_been_modified = true
	
	add_child(enemy_cards[pos]) # Create card
	
	enemy_cards[pos].UpdateStats(enemy_cards[pos])
	
	lymph -= enemy_cards[pos].Cost # Update lymph used by enemy
	
	UpdateEnemyHand()
	
	if enemy_cards[pos].get_node_or_null("Common Effects/Rise").get_script():
		enemy_cards[pos].get_node("Common Effects/Rise").Effect("enemy", enemy_cards[pos].Position) # Call 'Rise' function of the played card
	get_tree().call_group("OnDeploy", "Effect", "enemy", pos, enemy_cards[pos]) # Call 'On Deploy' functions
	
	enemy_field_cards.append(enemy_cards[pos]) # Add card to the array to simplify the founding of it
	
	get_tree().call_group("GUI_Manager", "_on_Update")

func MoveEnemyCard(old_pos, new_pos, new_loc):
	var positioner_pos = get_tree().get_first_node_in_group("EP"+str(new_pos))
	enemy_cards[old_pos].global_position = positioner_pos.global_position - Vector2(0,20) # Swap cards position
	enemy_cards[new_pos] = enemy_cards[old_pos] # Add new position to card dict
	enemy_cards.erase(old_pos) # Remove old position from card dict
	
	enemy_cards[new_pos].Position = new_pos
	enemy_cards[new_pos].currentLoc.clear()
	enemy_cards[new_pos].currentLoc.append(new_loc)
	
	enemy_cards[new_pos].SetOnMini()
	enemy_cards[new_pos].ShiftBack()
	
	for i in player_attacks: # if someone was attacking him than keep doing it
		if player_attacks[i] == old_pos:
			player_attacks[i] = new_pos
			break
	
	get_tree().call_group("OnMove", "Effect", self) # Call 'OnMove' functions
	
	get_tree().call_group("GUI_Manager", "_on_Update")

func PlayEnemyMagic(id):
	enemy_hand[-1].queue_free()
	enemy_hand.remove_at(enemy_hand.size() - 1) # Remove card from enemy hand
	
	var scene = load("res://Scenes/Game/Cards/Magic.tscn") # Load card resources
	var instance = scene.instantiate() # Instantiate card resources
	
	current_showed_card_ref.append(instance)
	current_showed_card_ref[-1].CreateCard(CardsList.getCardInfo(int(id)), int(id)) # Getting starter values
	current_showed_card_ref[-1].Team = "no" # avoid any type of interaction with the card
	current_showed_card_ref[-1].position = Vector2(65,110)
	current_showed_card_ref[-1].scale *= 2.2
	
	lymph -= instance.Cost # Update lymph used by enemy
	
	add_child(current_showed_card_ref[-1]) # Create card
	
	timer.append(Timer.new())
	timer[-1].connect("timeout" , ShowCard)
	timer[-1].wait_time = 3.5
	timer[-1].one_shot = true
	add_child(timer[-1])
	timer[-1].start()
	
	UpdateEnemyHand()
	
	instance.get_node("MagicEffect").Effect("enemy") # Call the magic effect of the played card
	get_tree().call_group("OnMagic", "Effect", "enemy") # Call 'OnMagic' functions

	get_tree().call_group("GUI_Manager", "_on_Update")

# Specific Effect #

func ShowOneCard(id): # Function called when played "Light on the dark" card
	var scene
	if CardsList.getCardInfo(int(id))["magic"]:
		scene = load("res://Scenes/Game/Cards/Magic.tscn") # Load card resources
	else:
		scene = load("res://Scenes/Game/Cards/Card.tscn") # Load card resources
	current_showed_card_ref.append(scene.instantiate()) # Instantiate card resources
	
	current_showed_card_ref[-1].CreateCard(CardsList.getCardInfo(int(id)), int(id)) # Getting starter values
	current_showed_card_ref[-1].Team = "no" # avoid any type of interaction with the card
	current_showed_card_ref[-1].position = Vector2(65,110)
	current_showed_card_ref[-1].scale *= 2.2
	
	add_child(current_showed_card_ref[-1]) # Create card
	
	timer.append(Timer.new())
	timer[-1].connect("timeout" , ShowCard)
	timer[-1].set_wait_time(3.5)
	timer[-1].one_shot = true
	add_child(timer[-1])
	timer[-1].start()

func ShowCard(): # Delete the card after 3.5 seconds
	current_showed_card_ref[0].queue_free()
	current_showed_card_ref.remove_at(0)

