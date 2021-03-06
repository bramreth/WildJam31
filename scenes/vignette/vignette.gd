extends Spatial

var rot_rate = Vector3.ZERO
var rot_speed = 0.1
var duration = 0

var root_spot_1 = Vector3(0,0,0)
var root_spot_2 = Vector3(0,5,-8)
var root_spot_3 = Vector3(0,-2,10)

# Called when the node enters the scene tree for the first time.
func _ready():
	shuffle()
	randomize()

func view_text(text_in):
	duration = 0
	$GunRig.visible = false
	$ammo_container.visible = false
	$text.visible = true
	$WorldEnvironment.environment.set("dof_blur_far_enabled", false)
	
	$Timer.start(2)
	shuffle_col(Color(randf(), randf(), randf()).contrasted())
#	$camera_root.rotation_degrees = Vector3(rand_range(-1,1),rand_range(-1,1),rand_range(-1,1))
	$camera_root.rotation_degrees.y = rand_range(-45, 45)
	$camera_root.rotation_degrees.x = rand_range(-15, 15)
	$camera_root.rotation_degrees.z = rand_range(-5, 5)
	$camera_root.translation = $text.global_transform.origin
	$text/Viewport/Label.text = text_in
	$camera_root/Camera.translation.z = rand_range(12, 18)
	if text_in.length() > 2:
		var t = text_in.replace(" ", "\n ")
		$text/Viewport/Label.text = t
		$camera_root/Camera.translation.z = 48

	rot_rate.y =  -$camera_root.rotation_degrees.y/30
	rot_rate.x =  -$camera_root.rotation_degrees.x/10
	rot_rate.z =  -$camera_root.rotation_degrees.z/4
	$camera_root/Camera/AnimationPlayer.seek(0, true)
	$camera_root/Camera/AnimationPlayer.play("zoom")
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	duration += delta
	$camera_root.rotate(rot_rate.normalized(), (delta/ duration) * rot_speed )

func shuffle_col(col: Color):
	$WorldEnvironment.environment.set("fog_color", col)
	$SpotLight.light_color = col.lightened(0.3)

func shuffle():
	$camera_root/Camera/AnimationPlayer.seek(0, true)
	$camera_root/Camera/AnimationPlayer.stop()
	$WorldEnvironment.environment.set("dof_blur_far_enabled", true)
	$text.visible = false
	$GunRig.visible = true
	for child in $ammo_container.get_children():
		child.visible = false
	$Timer.start(rand_range(1,5))
	shuffle_col(Color(randf(), randf(), randf()).contrasted())
	duration = 0
	$camera_root.rotation_degrees = Vector3(rand_range(-1,1),rand_range(-1,1),rand_range(-1,1))
	$GunRig/Gun/AnimationPlayer.playback_speed = rand_range(0.1, 1)
	
	if randf() < 0.66:
		$camera_root.translation = root_spot_1
		if randf() < 0.6:
			$GunRig.visible = false
			$ammo_container.get_child(rand_range(0, $ammo_container.get_child_count())).visible = true
	else:
		if randf()< 0.5:
			$camera_root.translation = root_spot_2
		else:
			$camera_root.translation = root_spot_3
	if randf() < 0.8:
		$GunRig/Gun/AnimationPlayer.seek(0, true)
		$GunRig/Gun/AnimationPlayer.play("fire")
	$camera_root.rotation_degrees.z = rand_range(-30, 30)
	var choice = randf()
	if choice < 0.25:
		rot_rate.x = 1
	elif choice < 0.5:
		rot_rate.x = -1
	elif choice < 0.75:
		rot_rate.y = -1
	else:
		rot_rate.y = 1
	var dist = rand_range(0.5, 1.5)
	$camera_root/Camera.translation.z = dist*15
	rot_speed = 0.1 / (2 - dist) # 1 close, 0 far

func _on_Timer_timeout():
	shuffle()
