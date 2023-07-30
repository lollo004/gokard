extends Area2D

var GameController # Game controller reference


func _ready(): #Setup first datas
	GameController = get_tree().get_first_node_in_group("GameController")


func _process(delta):
	global_position = lerp(global_position, get_global_mouse_position(), 25 * delta) # Move pointer with mouse


func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton: # Mouse
		if event.is_pressed(): # Mouse click
			if GameController.selected_card_to_attack: # If there is a target then target it
				get_tree().call_group("Card", "isAttackOk", GameController.started_attack_card, true)
				GameController.AttackResult(true)
			else: # Otherwise deselect the target
				get_tree().call_group("Card", "isAttackOk", GameController.started_attack_card, false)
				GameController.AttackResult(false)
			get_tree().call_group("Deactivable", "Enable", true)
			queue_free() # Delete the object at the end of selection or deselection

