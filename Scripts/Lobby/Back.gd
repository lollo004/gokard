extends Button


func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/Lobby/LoginAndRegister.tscn")
