extends Spatial

var target = Vector2.ZERO

func air_time(time_in):
	translation.y = clamp(13 * pow(time_in, 0.5), 0, 10)
	print(translation.y)

func try_drop():
	if translation.y > 0 and not $CurveTween.is_active():
		$CurveTween.play(0.2, translation.y, 0)

func juicy_gun(x_in, y_in):
	target.x = clamp(-x_in/6, -24, 24)
	target.y = clamp(-y_in/6, -24, 24)

func _on_CurveTween_curve_tween(sat):
	translation.y = sat

func _process(delta):
	if get_parent().out:
		rotation_degrees.y = lerp(rotation_degrees.y,0, delta * 5)
		rotation_degrees.z = lerp(rotation_degrees.z,0, delta * 5)
	else:
		rotation_degrees.y = lerp(rotation_degrees.y,target.x, delta * 5)
		rotation_degrees.z = lerp(rotation_degrees.z,target.y, delta * 5)
		target.linear_interpolate(Vector2.ZERO, delta * 3)
