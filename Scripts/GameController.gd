extends Control

### GAME VALUES ###

@export var player_healt : int = 30
@export var enemy_healt : int = 30
@export var lymph : int = 0
@export var stress : int = 0
@export var turn : String = "player"
@export var phase : String = "defense"

var player_current_stress : int = 0
var enemy_current_stress : int = 0

var max_lymph : int = 0
var max_stress : int = 0

var turnType : String = "" # Action to do in current turn (play, draw, lymph, stress)

### MAIN EVENTS ###


func _ready():
	var scene
	var instance
	
	for i in 10: #da sistemare posizionamento nella mano
		scene = load("res://Scenes/Cards/Card.tscn")
		instance = scene.instantiate()
		add_child(instance)
		instance.global_position = Vector2(350 + (46*i), 520)


func _process(delta):
	pass


### PUBLIC FUNCTION ###


func TurnButtonPressed():
	if phase == "defense":
		phase = "attack"
	else:
		phase = "defense"
		if turn == "player":
			turn = "enemy"
		else:
			turn = "player"


### TURN MANAGEMEN FUNCTIONS ###


func PlayCard():
	turnType = "play"
	pass #gioca una carta

func DrawCard():
	turnType = "draw"
	DrawOneCard()

func AddLymph():
	if lymph < max_lymph:
		turnType = "lymph"
		lymph += 1

func AddStress():
	if stress < max_stress:
		turnType = "stress"
		stress += 1


### OTHER FUNCTIONS ###

func DrawOneCard():
	pass
