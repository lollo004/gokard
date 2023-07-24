extends Area2D

## Card Variables ##

@export var Health : int = 0
@export var Attack : int = 0
@export var Speed : int = 0
@export var Weight : int = 0

@export var Cost : int = 0

@export var id : int = 0 # Univoc id to represent the card

@export var Name : String = ""
@export var Race : String = ""  # Race (human - magic - building - ecc.)
@export var Nature : String = "" # Nature (aggressive - normal - pacifist)

@export var Effect : String = "" # Effect in game
@export var Desription : String = "" # Lore

@export var Type : String = "" # Type (attack - defense - versatile)

@export var Team : String = "" # Team (player - enemy)

## Management Variables ##

var Position : String = "" # Position on the field (1-9)
var Location : String = "hand" # Location of the card (deck - hand - field - waste)

var isFirstTurn : bool = true # Variable used to disable the card on the first turn you play it
var isEnabled : bool = false # Variable to check if a card is enabled and you can interact with it

## Scale Variables ##

var minScale
var maxScale
var sprite

## Movement and Selection Variables ##

var isMouseOver : bool = false
var isCardSelected : bool = false

var currentPos : int = 0 # Current position on the field (0 => Invalid)
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

### MAIN EVENTS ###


func _ready(): # Function called only on start
	sprite = $AnimatedSprite2D
	minScale = sprite.scale
	maxScale = sprite.scale * 2


func _process(delta): # Function called every frame
	if Input.is_action_just_pressed("click") and isMouseOver and isEnabled: # Click over a card with mouse
		if Team == "player" and GameController.turn == "player":
			if isCardSelected: # Dropping the card
				if (
					currentPos != 0 # Right position
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
					
					GameController.lymph -= Cost
					GameController.player_current_stress += 1
					
					GameController.player_hand.remove_at(GameController.player_hand.find(self))
					GameController.UpdateHand()
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
					
					var scene = load("res://Scenes/RuntimeScenes/EnemyPointer.tscn")
					var instance = scene.instantiate()
					add_child(instance)
					
					get_tree().call_group("Deactivable", "Enable", false)
				if Location == "field" and isTargetSelected and not isSearchingForEnemy and GameController.phase == "attack" and currentLoc == "Attack" and not isFirstTurn: # Deselecting the card to attack
					GameController.player_attacks.erase(self)
					isTargetSelected = false
				if Location == "field" and not isChooseDone and not isChoosingToDefend and GameController.phase == "defense" and currentLoc == "Defense" and not isFirstTurn: # Choosing what to do with the card
					GameController.started_defende_card = self
					isChoosingToDefend = true
					
					var scene = load("res://Scenes/RuntimeScenes/DefenseChoosing.tscn")
					var instance = scene.instantiate()
					add_child(instance)
					
					get_tree().call_group("Deactivable", "Enable", false)
					instance.global_position = global_position
				if Location == "field" and isChooseDone and not isChoosingToDefend and GameController.phase == "defense" and currentLoc == "Defense" and not isFirstTurn: # Cancel choose on the card
					GameController.player_defends.erase(self)
					isChooseDone = false
				
	
	if isCardSelected and isEnabled: # Drag
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta)
		sprite.scale = minScale


### MOUSE EVENTS ###


func _on_mouse_entered(): # Start override with mouse
	sprite.scale = maxScale
	isMouseOver = true


func _on_mouse_exited(): # Stop override with mouse
	sprite.scale = minScale
	isMouseOver = false


### COLLISION EVENTS ###


func _on_area_entered(area):
	if area.get_groups():
		if area.get_groups()[0] == "Positioner" and not isSearchingForEnemy and not isChoosingToDefend: # Dropping the card on a valid position
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


### GROUP RELATED ASYNC SIGNALS ###


func Enable(flag : bool): # Function called when a menu is appearing or disappearing
	isEnabled = flag


func isAttackOk(flag : bool, who): # Fuction called when a pointer is going to be deleted
	if who == self:
		if flag:
			isTargetSelected = true
		else:
			isTargetSelected = false
		isSearchingForEnemy = false


func isDefenseOk(who, what : String): # Fuction called when you choose what to do with a defender card
	if who == self:
		if what != "":
			isChooseDone = true
			actionDuringDefense = what
		else:
			isChooseDone = false
		isChoosingToDefend = false


func onTurnBegin(who): # Function called on turn start (who = player / enemy)
	if Team == who:
		if Location == "field":
			isFirstTurn = false
		
		if actionDuringDefense == "defende": #Toggle the block on turn start
			isBlockedByAbility = false


func onPhaseBegin(who): # Function called on attack phase start (who = player / enemy)
	if Team == who:
		if actionDuringDefense == "special": #Toggle the block on phase start
			isBlockedByAbility = false

