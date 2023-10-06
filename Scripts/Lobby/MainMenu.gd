extends Node


func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Game/ClientInstance.tscn") # add networking


func _on_shop_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Lobby/Shop.tscn")


func _on_deck_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Lobby/Deck.tscn")


func _on_quit_button_pressed():
	get_tree().quit()
