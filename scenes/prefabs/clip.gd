extends Spatial

var ammo_types = []
var ammo_index  = 0
var ammo = null

var new_ammo = 0

var starting_ammo = ["pencil"]

signal init()

func add_ammo(name_in: String):
	for i in ammo_types:
		if i.name == name_in:
			return
	for amm in $ammo_container.get_children():
		if amm.name == name_in:
			ammo_types.append(amm)
			new_ammo = ammo_types.find(amm)
	
#func swap_last_ammo():
#	print(last_index, " ", ammo_index)
#	var new_last = ammo_index
#	ammo_index = last_index
#	last_index = new_last
func swap_new_ammo():
	ammo_types[ammo_index].visible = false
	ammo_index = new_ammo
	swap_to_ammo()

func swap_ammo(forward: bool):
	if ammo: ammo.visible = false
	if len(ammo_types) == 1:
		swap_to_ammo()
		return
	if forward:
		ammo_index = (ammo_index + 1) % len(ammo_types)
	else:
		ammo_index = (ammo_index - 1) % (len(ammo_types)-1)
		if sign(ammo_index) == -1:
			ammo_index = (len(ammo_types)-2)-ammo_index
			
	swap_to_ammo()
	
	
func swap_to_ammo():
	ammo = ammo_types[ammo_index]
	$ammo_data/Viewport/ammo_data.setup(ammo)
	$AnimationPlayer.play("show")
	ammo.visible = true
	
func _ready():
	for amm in $ammo_container.get_children():
		if amm.name in starting_ammo:
			ammo_types.append(amm)
#	ammo_types = $ammo_container.get_children()
	ammo = ammo_types[ammo_index]
	ammo.visible = true
	$ammo_data/Viewport/ammo_data.setup(ammo)

func show_ammo(show: bool):
	$ammo_container.visible = true
	if show:
		$AnimationPlayer.play("show")
	else:
		$AnimationPlayer.play_backwards("show")
		
func tuck_ammo():
	$ammo_container.visible = false
	$AnimationPlayer.seek(0, true)

func show_dat(on):
	if on:
		$ammo_data/AnimationPlayer.play("show_dat")
	else:
		$ammo_data/AnimationPlayer.play_backwards("show_dat")

#func save_new_ammo():
#	if last_index != ammo_index:
#		last_index = ammo_index

func get_ammo_data():
	return ammo_types[ammo_index]
