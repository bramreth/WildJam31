extends Spatial

func _ready():
	randomize()
	shuf()
	



func shuf():
	var clist = [
		$machine.get_surface_material(0).albedo_color,
		$machine.get_surface_material(2).albedo_color,
		$machine.get_surface_material(3).albedo_color,
		$machine.get_surface_material(4).albedo_color,
		Color.white, 
		Color.black,
	]
	$machine.get_surface_material(1).albedo_color = clist[rand_range(0, len(clist))]
	$machine/OmniLight.light_color = $machine.get_surface_material(1).albedo_color
	if $machine/OmniLight.light_color == Color.black:
		$machine/OmniLight.light_energy = 0
	else:
		$machine/OmniLight.light_energy = 5


func _on_Timer_timeout():
	shuf()
	$Timer.start(rand_range(0.5, 1.9))
