extends Spatial

func _ready():
	randomize()

func shoot(rate_of_fire, spread = 1):
	$Gun/AnimationPlayer.play("reload")
	$Gun/AnimationPlayer.seek(0, true)
	$Gun/gun_sounds/shot.pitch_scale = ((3 * rate_of_fire) + rand_range(-0.02,0.02))
	$Gun/gun_sounds/shot.max_db = 1.0 - (6*spread)
	$Gun/AnimationPlayer.playback_speed = rate_of_fire
	$Gun/AnimationPlayer.play("fire")
	$Gun/gun_sounds/shot.pitch_scale = ((3 * rate_of_fire) + rand_range(-0.02,0.02))
	$Gun/gun_sounds/shot.max_db = 1.0 - (6*spread)
	
func reload():
	$Gun/AnimationPlayer.playback_speed = 1.0
	$Gun/AnimationPlayer.play("reload")
	
func ammo_tuck():
	$Gun/AnimationPlayer.playback_speed = 1.0
	$Gun/AnimationPlayer.play_backwards("reload (copy)")
	$Gun/animated_gun/ak47/clip/animclip/AnimationPlayer.play_backwards("show")
	
func ammo_look():
	$Gun/AnimationPlayer.playback_speed = 1.0
	$Gun/AnimationPlayer.play("reload (copy)")
	$Gun/animated_gun/ak47/clip/animclip/AnimationPlayer.play("show")
	
func _input(event):
	if Input.is_action_just_pressed("ui_down"):
		shoot(1, 1)
	elif Input.is_action_just_pressed("ui_up"):
		reload()
	elif Input.is_action_just_pressed("ui_left"):
		ammo_look()
	elif Input.is_action_just_pressed("ui_right"):
		ammo_tuck()
