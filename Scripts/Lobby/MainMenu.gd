extends Node


func _on_play_button_pressed():
	if len(Data.deck) == 40:
		get_tree().change_scene_to_file("res://Scenes/Game/ClientInstance.tscn")
	else:
		print("Deck must contain 40 cards!")


func _on_shop_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Lobby/Shop.tscn")


func _on_deck_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Lobby/Deck.tscn")


func _on_quit_button_pressed():
	get_tree().quit()
