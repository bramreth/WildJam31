extends Spatial

var ammo_types = []
var ammo_index  = 0
var ammo = null

var starting_ammo = ["cupcake", "sock", "cigarette"]

signal init()

func swap_ammo(forward: bool):
	if ammo: ammo.visible = false
	if forward:
		ammo_index = (ammo_index + 1) % len(ammo_types)
	else:
		ammo_index = (ammo_index - 1) % (len(ammo_types)-1)
		if sign(ammo_index) == -1:
			ammo_index = (len(ammo_types)-2)-ammo_index
			
		
	ammo = ammo_types[ammo_index]
	$AnimationPlayer.play("show")
	ammo.visible = true
	
func _ready():
	for amm in $ammo_container.get_children():
		if amm.name in starting_ammo:
			ammo_types.append(amm)
#	ammo_types = $ammo_container.get_children()
	ammo = ammo_types[ammo_index]
	ammo.visible = true

func show_ammo(show: bool):
	$ammo_container.visible = true
	if show:
		$AnimationPlayer.play("show")
	else:
		$AnimationPlayer.play_backwards("show")
		
func tuck_ammo():
	$ammo_container.visible = false
	$AnimationPlayer.seek(0, true)

func get_ammo_data():
	return ammo_types[ammo_index]
