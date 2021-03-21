extends "res://light_ball.gd"

func handle_light():
	var s = n.get_noise_1d(time)
	$OmniLight.light_energy = 2 + (abs(s)/2)
	$MeshInstance2.mesh.material.emission_energy = 1 + (abs(s)/2)
	
