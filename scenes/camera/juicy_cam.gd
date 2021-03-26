extends Camera

export (OpenSimplexNoise) var noise
export(float, 0, 1) var trauma = 0.0

export var max_x = 3
export var max_y = 3
export var max_r = 1

export var time_scale = 150

export(float, 0, 1) var decay = 0.6

var basefov = fov

var time = 0

onready var guncam = get_node("ViewportContainer/Viewport/GunCamera")

func add_trauma(trauma_in):
	trauma = clamp(trauma + trauma_in, 0, 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	guncam.global_transform = global_transform
	time += delta
	var shake = pow(trauma, 2)
	translation.x = noise.get_noise_4d(time * time_scale, 0, 0, 0) * max_x * shake
	translation.y = noise.get_noise_4d(0, time * time_scale, 0, 0) * max_y * shake
	rotation_degrees.x = noise.get_noise_4d(0, 0, time * time_scale, 0) * max_r * shake
	rotation_degrees.y = noise.get_noise_4d(0, 0, 0, time * time_scale) * max_r * shake
	if trauma > 0: trauma = clamp(trauma - (delta * decay), 0, 1)
