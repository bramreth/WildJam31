extends Camera

var starting_fov = fov

func _process(delta):
	if fov != starting_fov:
		fov = lerp(fov, starting_fov, delta * 5)
