extends Spatial


func add_trauma(trauma_in: int):
	$juicy_cam.add_trauma(trauma_in)
	
func fade_in():
	$juicy_cam/CanvasLayer/fader/AnimationPlayer.play("fade_in")

func fade_out():
	$juicy_cam/CanvasLayer/fader/AnimationPlayer.play_backwards("fade_in")

func _ready():
	fade_in()
	
func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		fade_out()
