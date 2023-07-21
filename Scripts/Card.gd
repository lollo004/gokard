extends Area2D

@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.


### MAIN EVENTS ###


func _ready(): # Function called only on start
	screen_size = get_viewport_rect().size
	


func _process(delta): # Function called every frame
	pass


### MOUSE EVENTS ###


func _on_mouse_entered(): # Start override with mouse 
	pass


func _on_mouse_exited(): # Stop override with mouse 
	pass


func _on_input_event(viewport, event, shape_idx): # Click on the card
	pass


### COLLISION EVENTS ###


func _on_body_entered(body): # Collision with other objects
	pass
