extends Spatial

var target = Vector2.ZERO

func air_time(time_in):
	print(time_in)
	translation.y = clamp(time_in*15, 0, 25)

func try_drop():
	if translation.y > 0 and not $CurveTween.is_active():
		$CurveTween.play(0.2, translation.y, 0)

func juicy_gun(x_in, y_in):
	target.x = -x_in/6
	target.y = -y_in/6

func _on_CurveTween_curve_tween(sat):
	translation.y = sat

func _process(delta):
	rotation_degrees.y = lerp(rotation_degrees.y,target.x, delta * 5)
	rotation_degrees.z = lerp(rotation_degrees.z,target.y, delta * 5)
	target.linear_interpolate(Vector2.ZERO, delta * 3)
