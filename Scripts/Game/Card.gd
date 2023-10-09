extends Area2D

## Card Variables ##

@export var Health : int = 0
@export var Attack : int = 0
@export var Speed : int = 0
@export var Weight : int = 0

@export var Cost : int = 0 # Lymph cost

@export var id : int = 0 # Univoc id to represent the card

@export var Name : String = ""
@export var Gene : String = ""  # Gene (human - magic - building - ecc.)
@export var Deviation : String = "" # Deviation (standard - mage - sage)

@export var Effect : String = "" # Effect in game
@export var Description : String = "" # Lore

@export var Type : String = "" # Type (attack - defense - versatile)

@export var Team : String = "" # Team (player - enemy)

## Management Variables ##

var Position : int = 0 # Position on the field (1-9 => field | 10 => Leader | 0 => Invalid)
var Location : String = "hand" # Location of the card (deck - hand - field - waste)

var isFirstTurn : bool = true # Variable used to disable the card on the first turn you play it
var isEnabled : bool = false # Variable to check if a card is enabled and you can interact with it

var GameController # Game controller reference

## Scale Variables ##

var minScale
var maxScale
var sprite

## Movement and Selection Variables ##

var isMouseOver : bool = false
var isCardSelected : bool = false
var alreadyMoved : bool = false

var currentPos : int = 0 # Current position on the field (1-9 => field | 10 => Leader | 0 => Invalid)
var old_position # First position of the card
var new_position # New position of the card
var currentLoc : String = "" # Type on the field (attack - defense)

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
	GameController = get_tree().get_first_node_in_group("GameController")
	
	for x in self.get_children():
		if "Border" in x.get_groups():
			sprite = x
	
	minScale = sprite.scale
	maxScale = sprite.scale * 2
	
	UpdateStats(self)


func _process(delta): # Function called every frame
	if isCardSelected and isEnabled: # Drag card with mouse
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta)
		sprite.scale = minScale


### MOUSE EVENTS ###


func _on_mouse_entered(): # Start override with mouse
	sprite.scale = maxScale
	isMouseOver = true


func _on_mouse_exited(): # Stop override with mouse
	sprite.scale = minScale
	isMouseOver = false


func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT and isMouseOver and isEnabled: # Click over a card with left mouse button
			if Team == "player" and GameController.turn == "player":
				if isCardSelected: # Dropping the card
					if (
						currentPos != 0 # Right position
						and GameController.positionStatus[currentPos] == false
						and GameController.lymph >= Cost # Enough lymph 
						and GameController.turn == "player" # Right turn
						and GameController.phase == "attack" # Right phase
						and GameController.turnType == "play" # RIght turn type
						and Location == "hand" # Right card
						and (Type == currentLoc or Type == "Versatile") # Right type
						and GameController.stress > GameController.player_current_stress # Enough stress
						):
						
						Location = "field"
						global_position = new_position
						Position = currentPos
						GameController.positionStatus[Position] = true
						
						GameController.lymph -= Cost
						GameController.player_current_stress += 1
						
						GameController.player_hand.remove_at(GameController.player_hand.find(self))
						GameController.UpdateHand()
						
						get_tree().call_group("GUI_Manager", "_on_Update")
						
						if get_node_or_null("Common Effects/Rise"):
							get_node("Common Effects/Rise").Effect(Team, Position) # Call 'Rise' function of the played card
						get_tree().call_group("On Deploy", "Effect", Team, Position) # Call 'On Deploy' functions
						
						get_tree().call_group("ClientInstance", "send_play_card", id, Position) # Send card and position to opponent
					else:
						global_position = old_position
					isCardSelected = false
				else:
					if Location == "hand": # Taking the card
						old_position = global_position
						isCardSelected = true
					if Location == "field" and not isTargetSelected and not isSearchingForEnemy and GameController.phase == "attack" and currentLoc == "Attack" and not isFirstTurn: # Selecting the card to attack
						GameController.started_attack_card = self
						isSearchingForEnemy = true
						
						var scene = load("res://Scenes/Game/RuntimeScenes/EnemyPointer.tscn")
						var instance = scene.instantiate()
						add_child(instance)
						
						get_tree().call_group("Deactivable", "Enable", false)
					if Location == "field" and isTargetSelected and not isSearchingForEnemy and GameController.phase == "attack" and currentLoc == "Attack" and not isFirstTurn: # Deselecting the card to attack
						GameController.CancelAttack(self)
						isTargetSelected = false
					if Location == "field" and not isChooseDone and not isChoosingToDefend and GameController.phase == "defense" and currentLoc == "Defense" and not isFirstTurn and not isBlockedByAbility: # Choosing what to do with the card
						GameController.started_defende_card = self
						isChoosingToDefend = true
						
						var scene = load("res://Scenes/Game/RuntimeScenes/DefenseChoosing.tscn")
						var instance = scene.instantiate()
						add_child(instance)
						
						get_tree().call_group("Deactivable", "Enable", false)
						instance.global_position = global_position
					if Location == "field" and isChooseDone and not isChoosingToDefend and GameController.phase == "defense" and currentLoc == "Defense" and not isFirstTurn and not isBlockedByAbility: # Cancel choose on the card
						GameController.CancelDefense(self)
						isChooseDone = false
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT and isMouseOver and isEnabled: # Click over a card with right mouse button
			if Team == "player" and GameController.turn == "player":
				if isCardSelected: # Dropping the card
					if (
						currentPos != 0 # Right position
						and GameController.positionStatus[currentPos] == false
						and GameController.turn == "player" # Right turn
						and GameController.phase == "attack" # Right phase
						and GameController.turnType == "draw" # RIght turn type
						and Location == "field" # Right card
						and Type == "Versatile" # Right type
						):
						
						global_position = new_position
						var oldPos = Position
						GameController.positionStatus[oldPos] = false
						Position = currentPos
						GameController.positionStatus[Position] = true
						
						alreadyMoved = true
						isFirstTurn = true
						
						get_tree().call_group("ClientInstance", "send_move_card", oldPos, Position) # Send old and new position to opponent
					else:
						global_position = old_position
					isCardSelected = false
				else:
					if Location == "field" and not isTargetSelected and not isSearchingForEnemy and not isChooseDone and not isChoosingToDefend and not alreadyMoved and GameController.phase == "attack" and Type == "Versatile" and GameController.turnType == "draw" and not isFirstTurn: # Move the card if it's versatile
						old_position = global_position
						isCardSelected = true


### COLLISION EVENTS ###


func _on_area_entered(area):
	if area.get_groups():
		if area.get_groups()[0] == "Positioner" and area.get_groups()[4] == "Player" and not isSearchingForEnemy and not isChoosingToDefend: # Dropping the card on a valid position
			currentPos = int(String(area.get_groups()[1]))
			currentLoc = String(area.get_groups()[2])
			new_position = area.global_position
		
		if area.get_groups()[0] == "Pointer": # Getting selected by the pointer
			if Team == "enemy":
				GameController.selected_card_to_attack = self


func _on_area_exited(area):
	if area.get_groups():
		if area.get_groups()[0] == "Positioner" and not isSearchingForEnemy and not isChoosingToDefend: # Exiting by dropping the card on a valid position
			currentPos = 0
			
		if area.get_groups()[0] == "Pointer": # Exiting by getting selected by the pointer
			if Team == "enemy":
				GameController.selected_card_to_attack = null


### OTHER FUNCTIONS ###


func get_all_children(in_node, arr:=[]):
	arr.push_back(in_node)
	for child in in_node.get_children():
		arr = get_all_children(child,arr)
	return arr


### GROUP RELATED ASYNC SIGNALS ###


func Enable(flag : bool): # Function called when a menu is appearing or disappearing
	isEnabled = flag


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


func UpdateStats(who): # Function called when card's stats change
	if who == self:
		if Health <= 0: # Check Card Health
			GameController.positionStatus[Position] = false
			
			if get_node_or_null("Common Effects/Tunnel"):
				get_node("Common Effects/Tunnel").Effect() # Call 'Tunnel' function of the played card
			if get_node_or_null("Common Effects/Heritage"):
				get_node("Common Effects/Heritage").Effect() # Call 'Heritage' function of the played card
			
			get_tree().call_group("Revenge", "Effect", Team, Position) # Call 'Revenge' function
			
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
			if "Description" in i.get_groups():
				i.text = Description
			if "Type" in i.get_groups():
				i.text = Type


func onTurnBegin(team): # Function called on turn start (team = player / enemy)
	if Team == team:
		if Location == "field":
			isFirstTurn = false
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
			
			### ||| !!! USE SPECIAL ABILITY !!! ||| ###
			print("special")


func AttackEnemy(enemy): # Function called when the card has to attack another one
	enemy.Health -= Attack
	get_tree().call_group("Card", "UpdateStats", enemy)
	get_tree().call_group("Uprising", "Effect", Team) # Call 'Uprising' functions
	get_tree().call_group("Rage", "Effect", Team) # Call 'Rage' functions
	get_tree().call_group("Teleport", "Effect", Team) # Call 'Teleport' function
	
	if get_node_or_null("Common Effects/Raising"):
		get_node("Common Effects/Raising").Effect() # Call 'Raising' function of the played card
	if get_node_or_null("Common Effects/Sweet Song"):
		get_node("Common Effects/Sweet Song").Effect() # Call 'Sweet Song' function of the played card
	if get_node_or_null("Common Effects/Bane"):
		get_node("Common Effects/Bane").Effect() # Call 'Bane' function of the played card
	if get_node_or_null("Common Effects/Super Bane"):
		get_node("Common Effects/Super Bane").Effect() # Call 'Super Bane' function of the played card


func ProtectByEnemy(enemy): # Function called when the card has to defende by another one
	enemy.Health -= Attack
	get_tree().call_group("Card", "UpdateStats", enemy)

