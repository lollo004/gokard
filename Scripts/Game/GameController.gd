extends Node

### Game Values ###

@export var player_health : int = 30
@export var enemy_health : int = 30
@export var lymph : int = 0
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

var player_hand = []
var player_deck = []

var isScreenTaken = true # Variable to check if you can interact with buttons

var positionStatus = { # Dictionary that contains position status
	1 : false, 2 : false, 3 : false, 4 : false, 5 : false, 6 : false, 7 : false, 8 : false, 9 : false
}

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
	## RANDOM HAND GEN ##
	var scene
	var instance
	
	for i in 30:
		var rng = RandomNumberGenerator.new()
		var number = rng.randf_range(1, 4)
		scene = load("res://Scenes/Game/Cards/Card"+str(int(number))+".tscn")
		instance = scene.instantiate()
		instance.Team = "player"
	
		player_deck.append(instance)
	
	var number_of_cards = 9
	
	for i in number_of_cards:
		add_child(player_deck[i])
		player_hand.append(player_deck[i])
		player_deck.remove_at(i)
	
	UpdateHand()
	## RANDOM HAND GEN ##
	
	get_tree().get_first_node_in_group("TurnManager").visible = true
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
		
		ManagePlayerDefense()
	
	elif turn == "player" and phase == "attack":
		turn = "enemy"
		phase = "defense"
		get_tree().call_group("Card", "onTurnBegin", "enemy")
	
	elif turn == "enemy" and phase == "defense":
		phase = "attack"
		get_tree().call_group("Card", "onPhaseBegin", "enemy")
		
		ManageEnemyDefense()
	
	get_tree().call_group("GUI_Manager", "_on_Update")


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


# Deck #

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
			@warning_ignore("integer_division")
			item.global_position = Vector2((540 - ((len(player_hand) / 2) * 48)) + (46*i), 520)
		else:
			@warning_ignore("integer_division")
			item.global_position = Vector2((520 - (((len(player_hand) - 1) / 2) * 48)) + (46*i), 520)

func ShuffleDeck():
	player_deck.shuffle()

# Attack and Defense #

func AttackResult(flag : bool): # Function called when an attack is confirmed or not setted
	if flag:
		player_attacks[started_attack_card] = selected_card_to_attack
		started_attack_card = null
		selected_card_to_attack = null
	else:
		started_attack_card = null
		selected_card_to_attack = null

func CancelAttack(who): # Function called when an attack is cancelled
	player_attacks.erase(who)
	started_attack_card = null
	selected_card_to_attack = null

func DefenseResult(flag : bool): # Function called when a defense is confirmed or not setted
	if flag:
		player_defends.append(started_defende_card)
		started_defende_card = null
	else:
		started_defende_card = null

func CancelDefense(who): # Function called when a defense is cancelled
	player_defends.erase(who)
	started_defende_card = null

func ManagePlayerDefense(): # Function that contains player defense system
	if enemy_attacks.size() > 0:
		if enemy_attacks.size() > player_defends.size():
			var slowests = []
			var targets = []
			
			while enemy_attacks.size() > player_defends.size():
				var first_obj = true
				
				for i in enemy_attacks: #iterate all the attackers
					if first_obj:
						slowests.append(i)
					elif i.Speed <= slowests[-1].Speed:
						if i.Speed == slowests[-1].Speed:
							if i.Weight > slowests[-1].Weight:
								slowests[-1] = i
						else:
							slowests[-1] = i
					first_obj = false
				
				targets.append(enemy_attacks[slowests[-1]]) #remember his target
				enemy_attacks.erase(slowests[-1]) #remove the slowest (it will be the last attacker)
			
			PlayerDefense()
			
			var x = 0
			slowests.reverse()
			targets.reverse()
			
			while x < len(slowests): #attackers attack the desired target
				Fight(slowests[x], targets[x], false)
				x += 1
			
		elif player_defends.size() > enemy_attacks.size(): # if there are more defenders that attackers then remove the slowest
			while player_defends.size() > enemy_attacks.size():
				var slowest = null
				
				for i in player_defends: #iterate all the defenders
					if not slowest:
						slowest = i
					elif i.Speed <= slowest.Speed:
						if i.Speed == slowest.Speed:
							if i.Weight > slowest.Weight:
								slowest = i
						else:
							slowest = i
				
				player_defends.erase(slowest) #remove the slowest
				
			PlayerDefense()
		else:
			PlayerDefense()

func PlayerDefense():
	var n_times = enemy_attacks.size()
	
	for n in n_times: # used only to make this operation for every attacker
		var quicker_attacker
		var quicker_defender
		
		for i in enemy_attacks: #iterate all the attackers
			if not quicker_attacker:
				quicker_attacker = i
			elif i.Speed >= quicker_attacker.Speed:
				if i.Speed == quicker_attacker.Speed:
					if i.Weight < quicker_attacker.Weight:
						quicker_attacker = i
				else:
					quicker_attacker = i
		
		for i in player_defends: #iterate all the defenders
			if not quicker_defender:
				quicker_defender = i
			elif i.Speed >= quicker_defender.Speed:
				if i.Speed == quicker_defender.Speed:
					if i.Weight < quicker_defender.Weight:
						quicker_defender = i
				else:
					quicker_defender = i
		
		enemy_attacks.erase(quicker_attacker) #remove faster from the attackers
		player_defends.erase(quicker_defender) #remove faster from the defenders
		
		Fight(quicker_attacker, quicker_defender, true) #let's fight

func ManageEnemyDefense(): # Function that contains enemy defense system
	if player_attacks.size() > 0:
		if player_attacks.size() > enemy_defends.size():
			var slowests = []
			var targets = []
			
			while player_attacks.size() > enemy_defends.size():
				var first_obj = true
				
				for i in player_attacks: #iterate all the attackers
					if first_obj:
						slowests.append(i)
					elif i.Speed <= slowests[-1].Speed:
						if i.Speed == slowests[-1].Speed:
							if i.Weight > slowests[-1].Weight:
								slowests[-1] = i
						else:
							slowests[-1] = i
					first_obj = false
				
				targets.append(player_attacks[slowests[-1]]) #remember his target
				player_attacks.erase(slowests[-1]) #remove the slowest (it will be the last attacker)
			
			EnemyDefense()
			
			var x = 0
			slowests.reverse()
			targets.reverse()
			
			while x < len(slowests): #attackers attack the desired target
				Fight(slowests[x], targets[x], false)
				x += 1
			
		elif enemy_defends.size() > player_attacks.size(): # if there are more defenders that attackers then remove the slowest
			while enemy_defends.size() > player_attacks.size():
				var slowest = null
				
				for i in enemy_defends: #iterate all the defenders
					if not slowest:
						slowest = i
					elif i.Speed <= slowest.Speed:
						if i.Speed == slowest.Speed:
							if i.Weight > slowest.Weight:
								slowest = i
						else:
							slowest = i
				
				enemy_defends.erase(slowest) #remove the slowest
				
			EnemyDefense()
		else:
			EnemyDefense()

func EnemyDefense():
	var n_times = player_attacks.size()
	
	for n in n_times: # used only to make this operation for every attacker
		var quicker_attacker
		var quicker_defender
		
		for i in player_attacks: #iterate all the attackers
			if not quicker_attacker:
				quicker_attacker = i
			elif i.Speed >= quicker_attacker.Speed:
				if i.Speed == quicker_attacker.Speed:
					if i.Weight < quicker_attacker.Weight:
						quicker_attacker = i
				else:
					quicker_attacker = i
		
		for i in enemy_defends: #iterate all the defenders
			if not quicker_defender:
				quicker_defender = i
			elif i.Speed >= quicker_defender.Speed:
				if i.Speed == quicker_defender.Speed:
					if i.Weight < quicker_defender.Weight:
						quicker_defender = i
				else:
					quicker_defender = i
		
		player_attacks.erase(quicker_attacker) #remove faster from the attackers
		player_defends.erase(quicker_defender) #remove faster from the defenders
		
		Fight(quicker_attacker, quicker_defender, true) #let's fight

func Fight(attacker, defender, canDefend : bool):
	attacker.AttackEnemy(defender) #attacker attack the defender
	
	if canDefend:
		print("Fight --> " + attacker.Name + " vs " + defender.Name + " (defending himself)")
		defender.ProtectByEnemy(attacker) #defender protect himself only if the proprietary decided to defend
	else:
		print("Fight --> " + attacker.Name + " vs " + defender.Name + " (without defending himself)")
	
	get_tree().call_group("GUI_Manager", "_on_Update")
	get_tree().call_group("Leader", "_on_Update")

# Management #

func Enable(flag : bool): # Function called when a menu is appearing or disappearing
	isScreenTaken = not flag

# Game Result #

func GameEnds(looser): # Function called when someone dies (looser = who died)
	if looser == "player":
		print(str(player_name) + " died!")
	if looser == "enemy":
		print(str(enemy_name) + " died!")

