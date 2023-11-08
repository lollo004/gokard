extends Node


func Effect(Team, _Position): # Reveal one random card from enemy hand
	if Team == "enemy":
		get_tree().call_group("ClientInstance", "send_effect_114") # Send card to your opponent
