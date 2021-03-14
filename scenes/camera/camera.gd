extends Spatial

var spread = 1.0 

func add_trauma(trauma_in: float):
	$juicy_cam.add_trauma(trauma_in)
	
func fade_in():
	$juicy_cam/CanvasLayer/fader/AnimationPlayer.play("fade_in")

func fade_out():
	$juicy_cam/CanvasLayer/fader/AnimationPlayer.play_backwards("fade_in")

func _ready():
	fade_in()
	
func _input(event):
	pass
#		spread = spread + 30.0
#		$juicy_cam/CanvasLayer/CenterContainer/anchor/cross.rotation_degrees += 22
#		spread(spread)

func _physics_process(delta):
	var rot = $juicy_cam/CanvasLayer/CenterContainer/anchor/cross.rotation_degrees
#	var targ = (1 + floor($juicy_cam/CanvasLayer/CenterContainer/anchor/cross.rotation_degrees/ 90)) * 90
#
#	$juicy_cam/CanvasLayer/CenterContainer/anchor/cross.rotation_degrees = lerp(
#		$juicy_cam/CanvasLayer/CenterContainer/anchor/cross.rotation_degrees,
#		targ,
#		delta * 2
#	)

func spread(radius: float):
	var l = $juicy_cam/CanvasLayer/CenterContainer/anchor/cross/l
	var u = $juicy_cam/CanvasLayer/CenterContainer/anchor/cross/u
	var r = $juicy_cam/CanvasLayer/CenterContainer/anchor/cross/r
	var d = $juicy_cam/CanvasLayer/CenterContainer/anchor/cross/d
	l.position.x = -radius
	u.position.y = -radius
	r.position.x = radius
	d.position.y = radius
#	cross.scale = Vector2(radius, radius)


func _on_gun_spread(amount):
	spread(amount)


func fire_bullet(radius:float) -> void:
	var x:float = rand_range(0, radius*10) * sin(rand_range(0, 2 * PI))
	var y:float = rand_range(0, radius*10) * cos(rand_range(0, 2 * PI))
	$juicy_cam/RayCast.enabled = true
	$juicy_cam/RayCast.cast_to = Vector3(x,y,-100)
	$juicy_cam/RayCast.force_raycast_update()
	if $juicy_cam/RayCast.is_colliding():
		$juicy_cam/RayCast/DebugHitDetector.global_transform.origin = $juicy_cam/RayCast.get_collision_point()
		$juicy_cam/RayCast/DebugHitDetector/spatial_pqueue.trigger()
		var collider = $juicy_cam/RayCast.get_collider()
		var norm = $juicy_cam/RayCast.get_collision_normal()
		$juicy_cam/RayCast/DebugHitDetector/spatial_pqueue_cloud.get_next_particle().look_at(norm, Vector3(0,1,0))
		$juicy_cam/RayCast/DebugHitDetector/spatial_pqueue_cloud.trigger()
		var sprite = $juicy_cam/RayCast/DebugHitDetector/spatial_pqueue_sprite.get_next_particle()
		sprite.look_at(norm, Vector3(0,1,0))
		if am:
			sprite.draw_pass_1.material.albedo_texture = am
		$juicy_cam/RayCast/DebugHitDetector/spatial_pqueue_sprite.trigger()
		if collider.is_in_group('enemy'):
			$juicy_cam/CanvasLayer/CenterContainer/anchor/crosshair/AnimationPlayer.play("hit")
			collider.damage(1)
	$juicy_cam/RayCast.enabled = true


func _on_gun_fired():
	print("fired")
	fire_bullet(spread)
	add_trauma(0.1)

func _on_gun_reload():
	$juicy_cam/CanvasLayer/gui/clipflat/AnimationPlayer.play("reload")


func _on_gun_update_ammo(ammo, spread):
	$juicy_cam/CanvasLayer/gui/ammo.text = str(ammo)

var am = null

func _on_gun_change_ammo_type(ammo_ref):
	am = ammo_ref.icon
	$juicy_cam/CanvasLayer/gui/ammo_type.texture = ammo_ref.icon
	$juicy_cam/CanvasLayer/gui/ammo_type/AnimationPlayer.play("set_ammo")
