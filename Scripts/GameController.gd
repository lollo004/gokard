extends Control


### GAME VALUES ###
var player_healt : int = 30
var enemy_healt : int = 30
var lymph : int = 0
var stress : int = 0
var turn : String = "player"
var phase : String = "defense"


### OTHER VALUES ###
var test = null


func _ready():
	var scene
	
	for i in 10: #da sistemare posizionamento nella mano
		scene = load("res://Scenes/Cards/Card.tscn")
		var instance = scene.instantiate()
		add_child(instance)
		instance.position = Vector2(350 + (45*i), 520)


func _process(delta):
	pass
