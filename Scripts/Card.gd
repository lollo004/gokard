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

## Management Variables ##

var Position : String = "" # Position on the field (1-9)
var Location : String = "hand" # Location of the card (deck - hand - field - waste)

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
var currentLoc : String = ""

### MAIN EVENTS ###


func _ready(): # Function called only on start
	sprite = $AnimatedSprite2D
	minScale = sprite.scale
	maxScale = sprite.scale * 2


func _process(delta): # Function called every frame
	if Input.is_action_just_pressed("click") and isMouseOver: # Click over a card with mouse
		if isCardSelected: # Dropping the card
			if currentPos != 0 and GameController.lymph >= Cost and GameController.turn == "player" and GameController.phase == "attack" and Location == "hand" and (Type == currentLoc or Type == "Versatile"): # Right position, right turn-phase and enough lymph
				Location = "field"
				global_position = new_position
				GameController.lymph -= Cost
			else:
				global_position = old_position
			isCardSelected = false
		else: # Taking the card
			old_position = global_position
			isCardSelected = true
		
	if isCardSelected: # Drag
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
	if area.get_groups()[0] == "Positioner":
		currentPos = int(String(area.get_groups()[1]))
		currentLoc = String(area.get_groups()[2])
		new_position = area.global_position


func _on_area_exited(area):
	if area.get_groups()[0] == "Positioner":
		currentPos = 0
