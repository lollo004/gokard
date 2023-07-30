extends Node


func _on_login_pressed():
	get_tree().change_scene_to_file("res://Scenes/Lobby/Login.tscn")


func _on_register_pressed():
	get_tree().change_scene_to_file("res://Scenes/Lobby/Register.tscn")
