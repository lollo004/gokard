extends Area2D

@export var icon : Sprite2D
@export var text : Label

var id = 0

var isOver : bool = false

var Deck

var isInCollider = false # Variable used to disable the card if it's over right collider


func _ready():
	Deck = get_tree().get_first_node_in_group("Deck")


func CreateUID(i, n, e):
	id = i
	
	icon.texture = load("res://Resources/Images/Card"+str(i)+".png")
	text.text = n + ":\n" + e
	
	text.hide()


func _on_mouse_entered():
	text.show()
	
	isOver = true


func _on_mouse_exited():
	text.hide()
	
	isOver = false


func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT and isOver and isInCollider:
			Deck.decks[Deck.current_deck_pos].erase(id)
			Deck.UpdateDeck()
			
			get_tree().call_group("Card", "RemoveFromDeck", id)
			
			queue_free()


func _on_area_entered(area):
	if area.get_groups()[0] == "Current Deck Collider":
		isInCollider = true
		show()


func _on_area_exited(area):
	if area.get_groups()[0] == "Current Deck Collider":
		isInCollider = false
		hide()

