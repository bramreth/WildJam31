extends Spatial

onready var fader_animation_player:AnimationPlayer = $juicy_cam/UILayer/fader/AnimationPlayer
onready var camera:Camera = $juicy_cam
onready var gun = $juicy_cam/gun

onready var shot_raycast:RayCast = $juicy_cam/RayCast
onready var debug_hit_detector = $juicy_cam/RayCast/DebugHitDetector

var balloon = preload("res://scenes/prefabs/balloon.tscn")

var is_sprinting = false
var respawn = false

var selected_interactible = null

func add_trauma(trauma_in: float):
	camera.add_trauma(trauma_in)


func fade_in():
	fader_animation_player.play("fade_in")

func fade_out():
	gun.drop()
	fader_animation_player.playback_speed = 0.66
	fader_animation_player.play_backwards("fade_in")

func _ready():
	Event.connect(Event.ON_FIELD_OF_VIEW_CHANGED, self, "set_fov")
	fade_in()
	
func set_cam_env(env_in):
	$juicy_cam/ViewportContainer/Viewport/GunCamera.environment = env_in
	
func set_fov(fov_in):
	camera.basefov = fov_in
	camera.fov = camera.basefov

func _physics_process(delta):
	var tilt = PI/30
	if is_sprinting: 
		tilt *= 2
		camera.fov = lerp(camera.fov, camera.basefov + 15, delta*15)
	else:
		camera.fov = lerp(camera.fov, camera.basefov, delta*5)
	var lean_speed = delta * 2
	if not get_parent().is_on_floor(): lean_speed *= 5
	if Input.is_action_pressed("move_left"):
		camera.rotation.z = lerp(camera.rotation.z, tilt, lean_speed)
	elif Input.is_action_pressed("move_right"):
		camera.rotation.z = lerp(camera.rotation.z, -tilt, lean_speed)
	else:
		camera.rotation.z = lerp(camera.rotation.z, 0, lean_speed * 2)


func fire_bullet(radius:float) -> void:
	var x:float = rand_range(0, radius * .1) * sin(rand_range(0, 2 * PI))
	var y:float = rand_range(0, radius * .1) * cos(rand_range(0, 2 * PI))
	shot_raycast.enabled = true
	shot_raycast.cast_to = Vector3(x,y,-100)
	shot_raycast.force_raycast_update()
	if shot_raycast.is_colliding():
		debug_hit_detector.global_transform.origin = shot_raycast.get_collision_point()
		ParticleEventBus.request_particles(
			[ParticleEventBus.HIT, ParticleEventBus.CLOUD], 
			shot_raycast.get_collision_point(), 
			{'norm': shot_raycast.get_collision_normal()}
			)
		ParticleEventBus.request_particles(
			[ParticleEventBus.SPRITE],
			shot_raycast.get_collision_point(), 
			{
				'norm': shot_raycast.get_collision_normal(),
				'icon': gun.selected_ammo.get_ammo().icon
			}
			)
		var collider = shot_raycast.get_collider()
		var norm = shot_raycast.get_collision_normal()
		
		if collider.is_in_group('hitbox'):
			var enemy = collider.owner
			var ammo_dat =  gun.selected_ammo.get_ammo()
			var dmg = floor(rand_range(ammo_dat.dmg_min, ammo_dat.dmg_max+1))
			if collider.is_weakspot:
				collider.trigger()
				dmg *= 2
				$juicy_cam/RayCast/DebugHitDetector/AudioCrit.play(0)
			else:
				$juicy_cam/RayCast/DebugHitDetector/AudioHit.play(0)
			$juicy_cam/UILayer/CenterContainer.hit_confirmed()
			
			var crit = false
			if randf() < ammo_dat.crit_rate:
				crit = true
				dmg *= ammo_dat.crit_mul
			
			ParticleEventBus.request_particles(
				[ParticleEventBus.DAMAGE],
				shot_raycast.get_collision_point(), 
				{
					'norm': shot_raycast.get_collision_normal(),
					'dmg': dmg,
					'crit': crit,
					'color': ammo_dat.dmg_col
				}
			)
			
			var knockback = Vector3.ZERO
			if ammo_dat.knockback > 0:
				knockback = get_parent().global_transform.origin.direction_to(collider.global_transform.origin)
				knockback.normalized()
				knockback = knockback * ammo_dat.knockback
			if ammo_dat.balloon:
				if get_tree().get_nodes_in_group("bqueue").front().get_child_count() > 32:
					get_tree().get_nodes_in_group("bqueue").front().get_children().pop_back().queue_free()
				var b = balloon.instance()
				get_tree().get_nodes_in_group("bqueue").front().add_child(b)
				b.attach(enemy)
			enemy.damage(dmg, knockback)
			Game.add_hscore(dmg)
			enemy.apply_element(ammo_dat)
		else:
			$juicy_cam/RayCast/DebugHitDetector/AudioDud.play(0)
	shot_raycast.enabled = true


func fire_projectile(spread, projectile = null):
	var p = projectile.instance()
	get_tree().get_nodes_in_group('level').front().add_child(p)
	p.global_transform.origin = gun.get_projectile_spawn()
	p.fire_at(-global_transform.basis.z)


func _on_gun_fired(spread, is_projectile, projectile = null):
	if is_projectile:
		fire_projectile(spread, projectile)
	else:
		var ammo_dat =  gun.selected_ammo.get_ammo()
		if ammo_dat.is_shotgun:
			for i in range(ammo_dat.pellets):
				fire_bullet(spread+200)
				yield(get_tree(),"idle_frame")
		else:
			fire_bullet(spread)


func update_health(health, armor) -> void:
	$juicy_cam/UILayer/gui.update_health(health, armor)


func sprint_spread_multiplier(is_sprinting:bool):
	self.is_sprinting = is_sprinting
	gun.is_sprinting = is_sprinting
	
func warp(respawn_in):
	if not $CurveTween.is_active():
		respawn = respawn_in
		$CurveTween.play(0.3, $juicy_cam.fov, 1)

func _input(event):
	if Input.is_action_just_pressed("interact") and selected_interactible:
		selected_interactible.pickup()
	if Input.is_action_just_pressed("ui_page_up"):
		warp(false)

func _on_CurveTween_curve_tween(sat):
	$juicy_cam.fov = sat
	$juicy_cam/ViewportContainer/Viewport/GunCamera.fov = sat


func _on_CurveTween_tween_all_completed():
	if respawn:
		Event.emit_signal(Event.RESPAWN)
	else:
		Event.emit_signal(Event.WARP)


func _on_InteractibleArea_area_entered(area):
	if area.is_in_group("drop"):
		selected_interactible = area.get_parent()
		selected_interactible.select(true)
		$juicy_cam/UILayer/gui._on_gun_new_ammo(area.get_parent().get_pickup())

func _on_InteractibleArea_area_exited(area):
	if selected_interactible: selected_interactible.select(false)
	$juicy_cam/UILayer/gui.tuck_ammo()
	selected_interactible = null
