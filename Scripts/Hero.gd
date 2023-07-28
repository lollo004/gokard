extends Area2D

@export var Team : String = ""
var Name : String = ""
var Health : int = 30


func _ready(): #Setup first datas
	if Team == "player":
		Name = GameController.player_name
		Health = GameController.player_health
	if Team == "enemy":
		Name = GameController.enemy_name
		Health = GameController.enemy_health


func _process(delta): # Check if is still alive
	if Health <= 0:
		GameController.GameEnds(Team)
	
	if Team == "player":
		GameController.player_health = Health
	if Team == "enemy":
		GameController.enemy_health = Health


func _on_area_entered(area):
	if area.get_groups()[0] == "Pointer": # Getting selected by the pointer
		if Team == "enemy":
			GameController.selected_card_to_attack = self


func _on_area_exited(area):
	if area.get_groups()[0] == "Pointer": # Getting selected by the pointer
		if Team == "enemy":
			GameController.selected_card_to_attack = self

