extends Spatial

export (PackedScene) var cpickup
export (PackedScene) var upickup
export (PackedScene) var rpickup
export (PackedScene) var epickup

func spawn_pickup(r: int):
	if get_child_count() <= 0:
		match r:
			0:
				add_child(cpickup.instance())
			1:
				add_child(upickup.instance())
			2:
				add_child(rpickup.instance())
			3:
				return
				add_child(epickup.instance())
