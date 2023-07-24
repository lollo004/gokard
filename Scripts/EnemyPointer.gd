extends Area2D


func _process(delta):
	if Input.is_action_just_pressed("click"): # Click with mouse
		if GameController.selected_card_to_attack: # If there is a target then target it
			GameController.player_attacks[GameController.started_attack_card] = GameController.selected_card_to_attack
			get_tree().call_group("Card", "isAttackOk", true, GameController.started_attack_card)
		else: # Otherwise deselect the target
			get_tree().call_group("Card", "isAttackOk", false, GameController.started_attack_card)
		get_tree().call_group("Deactivable", "Enable", true)
		queue_free() # Delete the object at the end of selection or deselection
		
	global_position = lerp(global_position, get_global_mouse_position(), 25 * delta) # Move pointer with mouse

