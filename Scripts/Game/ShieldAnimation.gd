extends Sprite2D

var playing = true


func _physics_process(_delta):
	if playing:
		scale = Vector2.ZERO.lerp(Vector2(0.1,0.1), ($Timer.wait_time-$Timer.time_left)/$Timer.wait_time)


func Start():
	$Timer.connect("timeout" , End)
	$Timer.start()


func End():
	playing = false

