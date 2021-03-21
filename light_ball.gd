extends Spatial

export (OpenSimplexNoise) var n

var time = 0

func _process(delta):
	time += delta
	var s = n.get_noise_1d(time)
	if s > 0.1:
		$OmniLight.light_energy = 5 * s
		$MeshInstance2.mesh.material.emission_energy = s*3
	else:
		$OmniLight.light_energy = 0
		$MeshInstance2.mesh.material.emission_energy = 0
	
