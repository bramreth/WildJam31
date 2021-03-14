extends Spatial

var ammo_types = []
var ammo_index  = 0
var ammo = null

func swap_ammo(forward: bool):
	if ammo: ammo.visible = false
	if forward:
		ammo_index = (ammo_index + 1) % $ammo_container.get_child_count()
	else:
		print((ammo_index - 1) % ($ammo_container.get_child_count()-1))
		ammo_index = (ammo_index - 1) % ($ammo_container.get_child_count()-1)
		if sign(ammo_index) == -1:
			ammo_index = $ammo_container.get_child_count()-2-ammo_index
			
		
	ammo = $ammo_container.get_child(ammo_index)
	$AnimationPlayer.play("show")
	ammo.visible = true
	
func _ready():
	ammo = $ammo_container.get_child(ammo_index)
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
