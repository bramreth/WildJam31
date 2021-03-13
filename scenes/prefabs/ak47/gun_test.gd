extends Spatial

export (Curve) var spread_curve
var max_spread = 144
var spread = 0.0
var spread_decay = 0.04

var ammo = 30
var max_ammo = 30

signal spread(amount)
signal fired(ammo, spread)
signal reload()


func _process(delta):
	if not $AnimationPlayer.is_playing():
		if Input.is_action_pressed("click"):
			if ammo <= 0: 
				reload()
				return
			$AnimationPlayer.play("fire")
			drain_ammo()
			emit_signal("fired", ammo, spread)
			bullet_spread()
		$ak47.translation = $ak47.translation.linear_interpolate(Vector3.ZERO, delta * 5)
		$ak47.rotation_degrees.x = lerp_angle($ak47.rotation_degrees.x, 0, delta * 5)
		$ak47.rotation_degrees.y = lerp_angle($ak47.rotation_degrees.y, 0, delta * 5)
		$ak47.rotation_degrees.z = lerp_angle($ak47.rotation_degrees.z, 0, delta * 5)
	spread = clamp(spread - (0.66 * delta), 0, 1)
	emit_signal("spread", max_spread * spread_curve.interpolate(spread))
		
func _input(event):
	if not $AnimationPlayer.is_playing():
		if Input.is_action_just_pressed("reload"):
			reload()
			

func drain_ammo():
	ammo = clamp(ammo -1, 0, max_ammo)

func bullet_spread():
	spread = clamp(spread + 0.1, 0, 1)
	
func reload():
	$AnimationPlayer.play("reload")
	spread = clamp(spread - 0.2, 0, 1)
	emit_signal("reload")
		
func reset_ammo():
	ammo = max_ammo
	emit_signal("fired", ammo, spread)
