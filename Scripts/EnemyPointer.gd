extends Area2D


func _process(delta):
	if Input.is_action_just_pressed("click"): # Click with mouse
		if GameController.selected_card_to_attack: # If there is a target then target it
			get_tree().call_group("Card", "isAttackOk", GameController.started_attack_card, true)
			GameController.AttackResult(true)
		else: # Otherwise deselect the target
			get_tree().call_group("Card", "isAttackOk", GameController.started_attack_card, false)
			GameController.AttackResult(false)
		get_tree().call_group("Deactivable", "Enable", true)
		queue_free() # Delete the object at the end of selection or deselection
		
	global_position = lerp(global_position, get_global_mouse_position(), 25 * delta) # Move pointer with mouse
