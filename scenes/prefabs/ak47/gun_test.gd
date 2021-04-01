extends Spatial

export (Curve) var spread_curve

var is_sprinting:bool = false
var was_sprinting:bool = false
var spread = 0.0
var spread_decay = 0.04

var ammo = 30
var max_ammo = 30

var selected_ammo
signal spread(amount)
signal fired(spread, ammo_type)
signal update_ammo(ammo, spread)
signal reload()
signal change_ammo_type(ammo_ref, clip, reserve)
signal new_ammo(node)

var out = false

func _process(delta):
	spread = clamp(spread - (0.66 * delta), 0, 1)
	
	if is_sprinting: 
		spread = clamp(spread + 0.5, 0, 1)
		was_sprinting = true
	elif was_sprinting:
		spread = clamp(spread - 0.75, 0, 1)
		was_sprinting = false
	if not selected_ammo: return
	if not $AnimationPlayer.is_playing() and not out:
		if Input.is_action_pressed("click"):
			if $animated_gun/ak47/clip/animclip.can_fire():
				SteamRpc.tell_server_shot(selected_ammo.get_ammo().rof, spread)
				$gun_sounds/shot.pitch_scale = ((3 * selected_ammo.get_ammo().rof) + rand_range(-0.02,0.02))

				$gun_sounds/shot.max_db = 1.0 - (6*spread)

				$AnimationPlayer.playback_speed = selected_ammo.get_ammo().rof
				$AnimationPlayer.play("fire")
				
				emit_signal("update_ammo", selected_ammo.get_ammo(), selected_ammo.clip, selected_ammo.reserve, spread)
				emit_signal("fired", selected_ammo.get_ammo().weapon_spread * spread_curve.interpolate(spread), selected_ammo.get_ammo().is_projectile, selected_ammo.get_ammo().projectile)
				bullet_spread()
				$gun_sounds/shot.pitch_scale = ((3 * selected_ammo.get_ammo().rof) + rand_range(-0.02,0.02))
				$gun_sounds/shot.max_db = 1.0 - (6*spread)
			else:
				reload()
		$animated_gun/ak47.translation = $animated_gun/ak47.translation.linear_interpolate(Vector3.ZERO, delta * 5)
		$animated_gun/ak47.rotation_degrees.x = lerp_angle($animated_gun/ak47.rotation_degrees.x, 0, delta * 5)
		$animated_gun/ak47.rotation_degrees.y = lerp_angle($animated_gun/ak47.rotation_degrees.y, 0, delta * 5)
		$animated_gun/ak47.rotation_degrees.z = lerp_angle($animated_gun/ak47.rotation_degrees.z, 0, delta * 5)
	emit_signal("spread", selected_ammo.get_ammo().weapon_spread * spread_curve.interpolate(spread))
		
func _input(event):
	if out:
		if Input.is_action_just_pressed("click") or Input.is_action_just_pressed("reload"):
			shut_ammo_view()
#	else:
#		if Input.is_action_just_pressed("melee"):
#			$AnimationPlayer.play("melee_1")
	if not $AnimationPlayer.is_playing():
		if Input.is_action_just_pressed("reload"):
			reload()
	if Input.is_action_just_pressed("cycle_ammo") or Input.is_action_just_pressed("cycle_ammo_back"):
		if not out:
			open_ammo_view()
		$animated_gun/ak47/clip/animclip.swap_ammo(Input.is_action_just_pressed("cycle_ammo"))
		$animated_gun/ak47/clip/view_timeout.start(0)
	for i in range(1,5):
		if Input.is_action_just_pressed("ammo_" + str(i)):
			if not out:
				open_ammo_view()
			$animated_gun/ak47/clip/animclip.swap_ammo_num(i)
			$animated_gun/ak47/clip/view_timeout.start(0)
			return
			

func open_ammo_view():
	$AnimationPlayer.playback_speed = 1.0
	$AnimationPlayer.play("reload (copy)")
	$animated_gun/ak47/clip/animclip/AnimationPlayer.play("show")
	out = true
	$animated_gun/ak47/clip/view_timeout.start(0)
	$animated_gun/ak47/clip/animclip.show_dat(true)
		
func shut_ammo_view():
#	$ak47/clip/animclip.save_new_ammo()
	$AnimationPlayer.playback_speed = 1.0
	$AnimationPlayer.play_backwards("reload (copy)")
	$animated_gun/ak47/clip/animclip/AnimationPlayer.play_backwards("show")
	out = false
	#TODO get the current ammo type
	load_ammo_data()
	spread = clamp(spread - 0.2, 0, 1)
	$animated_gun/ak47/clip/animclip.show_dat(false)
	
func load_ammo_data():
	selected_ammo = $animated_gun/ak47/clip/animclip.get_ammo_data()
	max_ammo = selected_ammo.get_ammo().max_ammo
	emit_signal("change_ammo_type", selected_ammo.get_ammo(), selected_ammo.clip, selected_ammo.clip)
	reset_ammo()

func bullet_spread():
	spread = clamp(spread + 0.1, 0, 1)
	
func reload():
	SteamRpc.tell_server_reload()
	selected_ammo = $animated_gun/ak47/clip/animclip.get_ammo_data()
	if selected_ammo.reserve > 0:
		$animated_gun/ak47/clip/animclip.reload_current()
		$AnimationPlayer.playback_speed = 1.0
		$AnimationPlayer.play("reload")
		spread = clamp(spread - 0.2, 0, 1)
		emit_signal("reload", selected_ammo.clip, selected_ammo.reserve)
		
func reset_ammo():
#	ammo = max_ammo
	selected_ammo = $animated_gun/ak47/clip/animclip.get_ammo_data()
	emit_signal("update_ammo", selected_ammo.get_ammo(), selected_ammo.clip, selected_ammo.reserve, spread)

func drop():
	$AnimationPlayer.play("drop")

func _on_view_timeout_timeout():
	if out: shut_ammo_view()


func get_projectile_spawn():
	return $animated_gun/ak47/spatial_blast_queue.global_transform.origin


func _on_animclip_added_ammo(node):
	print("open ammo view")
	emit_signal("new_ammo", node.get_ammo())
	selected_ammo = $animated_gun/ak47/clip/animclip.get_ammo_data()
	load_ammo_data()
	if not out:
		open_ammo_view()
	
	$animated_gun/ak47/clip/animclip.swap_ammo_slot(node)
