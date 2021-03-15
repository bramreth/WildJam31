extends Spatial

export (Curve) var spread_curve

var spread = 0.0
var spread_decay = 0.04

var ammo = 30
var max_ammo = 30

var selected_ammo

signal spread(amount)
signal fired(spread)
signal update_ammo(ammo, spread)
signal reload()
signal change_ammo_type(ammo_ref)

var out = false

func _ready():
	load_ammo_data()

func _process(delta):
	if not $AnimationPlayer.is_playing() and not out:
		if Input.is_action_pressed("click"):
			if ammo <= 0: 
				reload()
				return
			$AnimationPlayer.playback_speed = selected_ammo.rof
			$AnimationPlayer.play("fire")
			drain_ammo()
			emit_signal("update_ammo", ammo, spread)
			emit_signal("fired", spread)
			bullet_spread()
		$ak47.translation = $ak47.translation.linear_interpolate(Vector3.ZERO, delta * 5)
		$ak47.rotation_degrees.x = lerp_angle($ak47.rotation_degrees.x, 0, delta * 5)
		$ak47.rotation_degrees.y = lerp_angle($ak47.rotation_degrees.y, 0, delta * 5)
		$ak47.rotation_degrees.z = lerp_angle($ak47.rotation_degrees.z, 0, delta * 5)
	spread = clamp(spread - (0.66 * delta), 0, 1)
	emit_signal("spread", selected_ammo.weapon_spread * spread_curve.interpolate(spread))
		
func _input(event):
	if out:
		if Input.is_action_just_pressed("click") or Input.is_action_just_pressed("reload"):
			shut_ammo_view()
	if not $AnimationPlayer.is_playing():
		if Input.is_action_just_pressed("reload"):
			reload()
	if Input.is_action_just_pressed("cycle_ammo") or Input.is_action_just_pressed("cycle_ammo_back"):
		if not out:
			open_ammo_view()
		$ak47/clip/animclip.swap_ammo(Input.is_action_just_pressed("cycle_ammo"))
		$ak47/clip/view_timeout.start(0)

func open_ammo_view():
	$AnimationPlayer.playback_speed = 1.0
	$AnimationPlayer.play("reload (copy)")
	$ak47/clip/animclip/AnimationPlayer.play("show")
	out = true
	$ak47/clip/view_timeout.start(0)
		
func shut_ammo_view():
	$AnimationPlayer.playback_speed = 1.0
	$AnimationPlayer.play_backwards("reload (copy)")
	$ak47/clip/animclip/AnimationPlayer.play_backwards("show")
	out = false
	#TODO get the current ammo type
	load_ammo_data()
	spread = clamp(spread - 0.2, 0, 1)
	reset_ammo()

func load_ammo_data():
	selected_ammo = $ak47/clip/animclip.get_ammo_data()
	max_ammo = selected_ammo.max_ammo
	emit_signal("change_ammo_type", selected_ammo)
	reset_ammo()
	

func drain_ammo():
	ammo = clamp(ammo -1, 0, max_ammo)

func bullet_spread():
	spread = clamp(spread + 0.1, 0, 1)
	
func reload():
	$AnimationPlayer.playback_speed = 1.0
	$AnimationPlayer.play("reload")
	spread = clamp(spread - 0.2, 0, 1)
	emit_signal("reload")
		
func reset_ammo():
	ammo = max_ammo
	emit_signal("update_ammo", ammo, spread)


func _on_view_timeout_timeout():
	if out: shut_ammo_view()
