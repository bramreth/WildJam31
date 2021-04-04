extends Spatial

export (OpenSimplexNoise) var n


var time = 0

func handle_light():
	var s = abs(n.get_noise_1d(time))
#	if s > 0.1:
	if s > 0.1 and not $AudioStreamPlayer3D.playing:
		$AudioStreamPlayer3D.play(0)
	$OmniLight.light_energy = 5 * s
	$MeshInstance2.mesh.material.emission_energy = s*3
#	else:
#		$AudioStreamPlayer3D.playing = false
#		$OmniLight.light_energy = 0
#		$MeshInstance2.mesh.material.emission_energy = 0

func _process(delta):
	time += delta
	handle_light()
	
	
