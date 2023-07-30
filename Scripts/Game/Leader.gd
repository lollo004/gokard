extends Area2D

@export var Team : String = ""
var Name : String = ""
var Health : int = 30

var GameController # Game controller reference


func _ready(): #Setup first datas
	GameController = get_tree().get_first_node_in_group("GameController")
	
	if Team == "player":
		Name = GameController.player_name
		Health = GameController.player_health
	if Team == "enemy":
		Name = GameController.enemy_name
		Health = GameController.enemy_health


func _on_Update():
	if Team == "player": # Update Stats
		GameController.player_health = Health
	if Team == "enemy": # Update Stats
		GameController.enemy_health = Health
	
	if Health <= 0: # Check if is still alive
		GameController.GameEnds(Team)


func _on_area_entered(area):
	if area.get_groups()[0] == "Pointer": # Getting selected by the pointer
		if Team == "enemy":
			GameController.selected_card_to_attack = self


func _on_area_exited(area):
	if area.get_groups()[0] == "Pointer": # Getting selected by the pointer
		if Team == "enemy":
			GameController.selected_card_to_attack = self

