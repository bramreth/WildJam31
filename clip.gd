extends Spatial


func show_ammo(show: bool):
	$ammo_container.visible = true
	if show:
		$AnimationPlayer.play("show")
	else:
		$AnimationPlayer.play_backwards("show")
		
func tuck_ammo():
	$ammo_container.visible = false
	$AnimationPlayer.seek(0, true)
