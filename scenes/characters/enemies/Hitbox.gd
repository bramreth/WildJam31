extends Area

export(bool) var is_weakspot = false

func get_class():
	return 'HitBox'

func trigger():
	$CollisionShape/spatial_pqueue.trigger()
	
