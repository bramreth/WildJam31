extends Spatial

func _process(delta):
	
	if not $AnimationPlayer.is_playing():
		if Input.is_action_pressed("click"):
			$AnimationPlayer.play("fire")
		$ak47.translation = $ak47.translation.linear_interpolate(Vector3.ZERO, delta * 5)
		$ak47.rotation_degrees.x = lerp_angle($ak47.rotation_degrees.x, 0, delta * 5)
		$ak47.rotation_degrees.y = lerp_angle($ak47.rotation_degrees.y, 0, delta * 5)
		$ak47.rotation_degrees.z = lerp_angle($ak47.rotation_degrees.z, 0, delta * 5)
		
func _input(event):
	if not $AnimationPlayer.is_playing():
		if Input.is_action_just_pressed("reload"):
			$AnimationPlayer.play("reload")
