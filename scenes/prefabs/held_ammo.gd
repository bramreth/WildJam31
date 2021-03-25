extends Spatial


func next_free_slot(active_slot):
	var next_slot = active_slot
	while next_slot.slot_taken():
		print(next_slot.name, next_slot.slot_taken())
		next_slot = next_slot.next_slot()
		if next_slot == active_slot: return null # we have reached the end
	return next_slot

func _ready():
	for child in get_children():
		child.visible = false

func add_ammo(name_in: String, amount:int = -1):
	for slot in get_children():
		if slot.name == name_in:
			if amount < 0:
				slot.reserve += slot.get_ammo().max_ammo * 2
			else:
				slot.reserve += amount
	#	var already_had = false
#	var added_ammo
#	for i in ammo_types.keys():
#		if i.name == name_in:
#			added_ammo = i
#			if amount < 0:
#				ammo_types[added_ammo]['reserve'] += added_ammo.max_ammo * 2
#			else:
#				ammo_types[added_ammo]['reserve'] += amount
#			already_had = true
	
#	if not already_had:
#		for amm in $ammo_container.get_children():
#			if amm.name == name_in:
#				added_ammo = amm
#				if amount < 0:
#					ammo_types[added_ammo] = {
#					'clip': 0,
#					'reserve': added_ammo.max_ammo * 2
#					}
#				else:
#					ammo_types[added_ammo] = {
#					'clip': 0,
#					'reserve': amount
#					}
#	new_ammo = ammo_types.keys().find(added_ammo)
#	if name_in == ammo_types.keys()[ammo_index].name: owner.emit_signal('update_ammo', added_ammo, ammo_types[added_ammo]['clip'], ammo_types[added_ammo]['reserve'], 0)
	
