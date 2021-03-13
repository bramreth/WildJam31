extends Spatial

var spread = 1.0 

func add_trauma(trauma_in: float):
	$juicy_cam.add_trauma(trauma_in)
	
func fade_in():
	$juicy_cam/CanvasLayer/fader/AnimationPlayer.play("fade_in")

func fade_out():
	$juicy_cam/CanvasLayer/fader/AnimationPlayer.play_backwards("fade_in")

func _ready():
	fade_in()
	
func _input(event):
	pass
#		$juicy_cam/CanvasLayer/CenterContainer/anchor/crosshair/AnimationPlayer.play("hit")
#		spread = spread + 30.0
#		$juicy_cam/CanvasLayer/CenterContainer/anchor/cross.rotation_degrees += 22
#		spread(spread)

func _physics_process(delta):
	var rot = $juicy_cam/CanvasLayer/CenterContainer/anchor/cross.rotation_degrees
#	var targ = (1 + floor($juicy_cam/CanvasLayer/CenterContainer/anchor/cross.rotation_degrees/ 90)) * 90
#
#	$juicy_cam/CanvasLayer/CenterContainer/anchor/cross.rotation_degrees = lerp(
#		$juicy_cam/CanvasLayer/CenterContainer/anchor/cross.rotation_degrees,
#		targ,
#		delta * 2
#	)

func spread(radius: float):
	var l = $juicy_cam/CanvasLayer/CenterContainer/anchor/cross/l
	var u = $juicy_cam/CanvasLayer/CenterContainer/anchor/cross/u
	var r = $juicy_cam/CanvasLayer/CenterContainer/anchor/cross/r
	var d = $juicy_cam/CanvasLayer/CenterContainer/anchor/cross/d
	l.position.x = -radius
	u.position.y = -radius
	r.position.x = radius
	d.position.y = radius
#	cross.scale = Vector2(radius, radius)



func _on_gun_spread(amount):
	spread(amount)


func _on_gun_fired():
	print("fired")
	add_trauma(0.1)
