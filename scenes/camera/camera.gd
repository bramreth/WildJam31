extends Spatial

onready var explosion = load('res://scenes/prefabs/projectiles/Explosion.tscn')

var is_sprinting = false

func add_trauma(trauma_in: float):
	$juicy_cam.add_trauma(trauma_in)
	
func fade_in():
	$juicy_cam/CanvasLayer/fader/AnimationPlayer.play("fade_in")

func fade_out():
	$juicy_cam/gun.drop()
	$juicy_cam/CanvasLayer/fader/AnimationPlayer.playback_speed = 0.66
	$juicy_cam/CanvasLayer/fader/AnimationPlayer.play_backwards("fade_in")

func _ready():
	Event.connect(Event.ON_FIELD_OF_VIEW_CHANGED, self, "set_fov")
	fade_in()
	
func set_fov(fov_in):
	$juicy_cam.basefov = fov_in
	$juicy_cam.fov = $juicy_cam.basefov

func _physics_process(delta):
	var rot = $juicy_cam/CanvasLayer/CenterContainer/anchor/cross.rotation_degrees
	var tilt = PI/30
	if is_sprinting: 
		tilt *= 2
		$juicy_cam.fov = lerp($juicy_cam.fov, $juicy_cam.basefov + 15, delta*5)
	else:
		$juicy_cam.fov = lerp($juicy_cam.fov, $juicy_cam.basefov, delta)
	var lean_speed = delta * 2
	if not get_parent().is_on_floor(): lean_speed *= 5
	if Input.is_action_pressed("move_left"):
		$juicy_cam.rotation.z = lerp($juicy_cam.rotation.z, tilt, lean_speed)
	elif Input.is_action_pressed("move_right"):
		$juicy_cam.rotation.z = lerp($juicy_cam.rotation.z, -tilt, lean_speed)
	else:
		$juicy_cam.rotation.z = lerp($juicy_cam.rotation.z, 0, lean_speed * 2)
		
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
	var x:float = rand_range(0, radius * .1) * sin(rand_range(0, 2 * PI))
	var y:float = rand_range(0, radius * .1) * cos(rand_range(0, 2 * PI))
	print(str(x) + ' - ' + str(y))
	$juicy_cam/RayCast.enabled = true
	$juicy_cam/RayCast.cast_to = Vector3(x,y,-100)
	$juicy_cam/RayCast.force_raycast_update()
	if $juicy_cam/RayCast.is_colliding():
		$juicy_cam/RayCast/DebugHitDetector.global_transform.origin = $juicy_cam/RayCast.get_collision_point()
#		var ex = explosion.instance()
#		get_tree().get_nodes_in_group('level').front().add_child(ex)
#		ex.global_transform.origin = $juicy_cam/RayCast.get_collision_point()
#		ex.explode()
		

		$juicy_cam/RayCast/DebugHitDetector/spatial_pqueue.trigger()
		var collider = $juicy_cam/RayCast.get_collider()
		var norm = $juicy_cam/RayCast.get_collision_normal()
		$juicy_cam/RayCast/DebugHitDetector/spatial_pqueue_cloud.get_next_particle().look_at(norm, Vector3(0,1,0))
		$juicy_cam/RayCast/DebugHitDetector/spatial_pqueue_cloud.trigger()
		var sprite = $juicy_cam/RayCast/DebugHitDetector/spatial_pqueue_sprite.get_next_particle()
		sprite.look_at(norm, Vector3(0,1,0))
		if $juicy_cam/gun.selected_ammo.icon:
			sprite.draw_pass_1.material.albedo_texture = $juicy_cam/gun.selected_ammo.icon
		$juicy_cam/RayCast/DebugHitDetector/spatial_pqueue_sprite.trigger()
		
		if collider.is_in_group('hitbox'):
			var enemy = collider.owner
			var ammo_dat =  $juicy_cam/gun.selected_ammo
			var dmg = floor(rand_range(ammo_dat.dmg_min, ammo_dat.dmg_max+1))
			if collider.is_weakspot:
				collider.trigger()
				dmg *= 2
				$juicy_cam/RayCast/DebugHitDetector/AudioCrit.play(0)
			else:
				$juicy_cam/RayCast/DebugHitDetector/AudioHit.play(0)
			$juicy_cam/CanvasLayer/CenterContainer/anchor/crosshair/AnimationPlayer.play("hit")
			#dmg number for enemy
			var dmg_num = $juicy_cam/RayCast/DebugHitDetector/spatial_pqueue_num.get_next_particle()
			
			if randf() < ammo_dat.crit_rate:
				dmg *= ammo_dat.crit_mul
				dmg_num.set_number_col_crit(dmg, ammo_dat.dmg_col)
			else:
				dmg_num.set_number_col(dmg, ammo_dat.dmg_col)
			dmg_num.look_at(norm, Vector3(0,1,0))
			$juicy_cam/RayCast/DebugHitDetector/spatial_pqueue_num.trigger()
			
			var knockback = Vector3.ZERO
			if ammo_dat.knockback > 0:
				knockback = get_parent().global_transform.origin.direction_to(collider.global_transform.origin)
				knockback.normalized()
				knockback = knockback * ammo_dat.knockback
			
			enemy.damage(dmg, knockback)
			Game.add_hscore(dmg)
			enemy.apply_element(ammo_dat)
		else:
			$juicy_cam/RayCast/DebugHitDetector/AudioDud.play(0)
	$juicy_cam/RayCast.enabled = true


func fire_projectile(spread, projectile = null):
	var p = projectile.instance()
	get_tree().get_nodes_in_group('level').front().add_child(p)
	p.global_transform.origin = $juicy_cam/gun.get_projectile_spawn()
	p.fire_at(-global_transform.basis.z)


func set_enemy_dmg(col, dmg, pos):
	var dmg_num = $juicy_cam/RayCast/DebugHitDetector/spatial_pqueue_num.get_next_particle()
	dmg_num.set_number_col(dmg, col)
	dmg_num.global_transform.origin = pos
	$juicy_cam/RayCast/DebugHitDetector/spatial_pqueue_num.trigger()

func _on_gun_fired(spread, is_projectile, projectile = null):
#	print("fired")
	if is_projectile:
		fire_projectile(spread, projectile)
	else:
		var ammo_dat =  $juicy_cam/gun.selected_ammo
		if ammo_dat.is_shotgun:
			for i in range(ammo_dat.pellets):
				fire_bullet(spread+200)
				yield(get_tree(),"idle_frame")
		else:
			fire_bullet(spread)
#	add_trauma(0.1)

func _on_gun_reload(clip, reserve):
	print(str(clip) + ' - ' + str(reserve))
	$juicy_cam/CanvasLayer/gui/ammo.text = str(clip)
	$juicy_cam/CanvasLayer/gui/maxammo.text = str(reserve)
	$juicy_cam/CanvasLayer/gui/clipflat/AnimationPlayer.play("reload")


func _on_gun_update_ammo(ammo_ref, clip, reserve, spread):
	$juicy_cam/CanvasLayer/gui/ammo_type.texture = ammo_ref.icon
	$juicy_cam/CanvasLayer/gui/ammo.text = str(clip)
	$juicy_cam/CanvasLayer/gui/maxammo.text = str(reserve)

func _on_gun_change_ammo_type(ammo_ref, clip, reserve):
	$juicy_cam/CanvasLayer/gui/ammo.text = str(clip)
	$juicy_cam/CanvasLayer/gui/maxammo.text = str(reserve)
	$juicy_cam/CanvasLayer/gui/ammo_type.texture = ammo_ref.icon
	$juicy_cam/CanvasLayer/gui/ammo_type/AnimationPlayer.play("set_ammo")


func update_health(health, armor) -> void:
	$juicy_cam/CanvasLayer/gui.update_health(health, armor)


func sprint_spread_multiplier(is_sprinting:bool):
	self.is_sprinting = is_sprinting
	$juicy_cam/gun.is_sprinting = is_sprinting
