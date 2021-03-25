extends Spatial

export  (NodePath) var next_slot_path
export  (NodePath) var last_slot_path

var reserve = 0
var clip = 0

func replace_ammo(ammo_in: Node):
	if slot_taken():
		for child in get_children():
			child.queue_free()
			remove_child(child)
	add_child(ammo_in)
	clip = ammo_in.max_ammo
	reserve = ammo_in.max_ammo * 2

func slot_taken():
	return get_child_count() > 0

func next_slot():
	return get_node(next_slot_path)
	
func last_slot():
	return get_node(last_slot_path)
	
func get_ammo():
	assert(slot_taken(), "attempt to get ammo in empty slot")
	return get_children().front()

func get_reserve():
	assert(slot_taken(), "attempt to get ammo in empty slot")
	return reserve

func get_clip():
	assert(slot_taken(), "attempt to get ammo in empty slot")
	return clip
