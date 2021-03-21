extends Spatial

export (PackedScene) var cpickup
export (PackedScene) var upickup
export (PackedScene) var rpickup
export (PackedScene) var epickup

func spawn_pickup(r: int):
	if get_child_count() <= 0:
		if r < 0.5:
			add_child(cpickup.instance())
		elif r < 0.75:
			add_child(upickup.instance())
		elif r < 0.9:
			add_child(rpickup.instance())
		else:
			add_child(epickup.instance())
