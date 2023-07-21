extends Control


### GAME VALUES ###
@export var player_healt : int = 30
@export var enemy_healt : int = 30
@export var lymph : int = 0
@export var stress : int = 0
@export var turn : String = "player"
@export var phase : String = "defense"


### OTHER VALUES ###
var test = null


func _ready():
	var scene
	
	for i in 10: #da sistemare posizionamento nella mano
		scene = load("res://Scenes/Cards/Card.tscn")
		var instance = scene.instantiate()
		add_child(instance)
		instance.global_position = Vector2(350 + (45*i), 520)


func _process(delta):
	get_tree().get_first_node_in_group("Lymph")


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


### OTHER ### !
