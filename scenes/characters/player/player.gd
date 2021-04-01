extends "res://scenes/characters/character.gd"
class_name Player

onready var camera:Camera = $camera/juicy_cam

func _ready():
	$camera.update_health(health, armor)
	SteamNetwork.register_rpcs(self,
		[
			["update_position", SteamNetwork.PERMISSION.SERVER],
#			["update_ready_players", SteamNetwork.PERMISSION.SERVER],
#			["start_game", SteamNetwork.PERMISSION.SERVER],
		]
	)
	SteamRpc.notify_ready()
	yield(SteamRpc, "all_ready")

func warp(on):
	$camera.warp(on)

func _physics_process(_delta: float) -> void:
	if dead: return
	if translation.y < -100:
		warp(true)
	if is_on_floor():
		$camera.gun_anim.try_drop()
	else:
		$camera.gun_anim.air_time(_hang_time)
	input_direction = get_input_direction()
	if is_on_floor():
		$camera.gun_anim.try_drop()
		wall_run = false
		if Input.is_action_just_pressed("move_jump"):
			_jump()
	elif is_running() and is_on_wall():
#		if Input.is_action_pressed("move_jump"):
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			if collision.collider.is_in_group("wall"):
				var dir_to_wall = global_transform.origin.direction_to(collision.position)
				var move_dir = calculate_move_direction()
				if dir_to_wall.angle_to(move_dir) < PI/2:
					wall_run = true
				if Input.is_action_just_pressed("move_jump"):
					_wall_jump(dir_to_wall)
	else:
		wall_run = false
	if not $WalkCarpet.is_playing() and input_direction and (is_on_floor() or is_on_wall()):
		$AudioStreamPlayer3D2.pitch_scale = 1.5 + randf()/15
		$WalkCarpet.playback_speed = 0.2 + (current_speed/ 20) + (int(is_on_wall()) * 0.6)
		$WalkCarpet.play("walk")
	
	if true: #NetworkHelper.is_multiplayer: 
		_sync_movement_with_network(_delta)

#region overrides
func calculate_move_direction() -> Vector3:
	var cam_xform:Transform = camera.get_global_transform()
	var move_direction:Vector3 = Vector3.ZERO
	move_direction += cam_xform.basis.z.normalized() * input_direction.z
	move_direction += cam_xform.basis.x.normalized() * input_direction.x
	move_direction.y = 0
	return move_direction.normalized()

func is_running() -> bool:
	var is_running = Input.is_action_pressed("move_sprint") and input_direction.z < 0
	$camera.sprint_spread_multiplier(is_running)
	return is_running
#region end

static func get_input_direction() -> Vector3:
	return Vector3(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"), 0, Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward"))

func set_cam_env(env):
	$camera.set_cam_env(env)


func _wall_jump(dir_to_wall) -> void:
	_hang_time = 0
	velocity.y = 0.75 *  jump_force
	velocity.x -= 80 * dir_to_wall.x
	velocity.z -= 80 * dir_to_wall.z
	current_snap = Vector3.ZERO

func _jump() -> void:
	velocity.y = jump_force
	current_snap = Vector3.ZERO

func add_health(health_in: int):
	health = clamp(health + health_in, 0, max_health)
	$camera.update_health(health, armor)
	
func add_armor(armor_in: int):
	armor = clamp(armor + armor_in, 0, max_armor)
	$camera.update_health(health, armor)
	

func damage(amount:int, knockback:Vector3 = Vector3.ZERO) -> void:
	.damage(amount, knockback)
	camera.add_trauma(0.6)
	$camera.update_health(health, armor)
	

func _on_death() -> void:
	dead = true
	$AnimationPlayer.play("die")
	$camera.fade_out()
	Event.emit_signal("on_game_over_wave_reached", get_tree().get_nodes_in_group('level').front().wave)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "die":
		get_tree().reload_current_scene()

var frame_updater = 0

func _sync_movement_with_network(_delta) -> void:
	frame_updater += _delta
	#20 times per second post data
	if frame_updater > 0.05:
		frame_updater = 0
		SteamRpc.tell_server_moved(global_transform.origin, rotation.y, 0.0)
		SteamRpc.send_ping()
#	rpc('update_position', global_transform.origin, rotation.y, 0.0)
#	if not SteamNetwork.is_server():
#	SteamNetwork.rpc_on_server(self, 'update_position', [global_transform.origin, rotation.y, 0.0])


remote func server_update_transform(new_transform: Transform) -> void:
	global_transform = new_transform
