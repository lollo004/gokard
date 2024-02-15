extends Sprite2D

var a = null
var b = null

var playing = true


func _physics_process(_delta):
	if Data.isInstanceValid(a) and Data.isInstanceValid(b) and playing:
		position = a.position.lerp(b.position, ($Timer.wait_time-$Timer.time_left)/$Timer.wait_time)


func Start():
	$Timer.connect("timeout" , End)
	$Timer.start()


func End():
	playing = false

