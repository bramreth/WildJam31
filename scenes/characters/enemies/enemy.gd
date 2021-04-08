extends "res://scenes/characters/rigidcharacter.gd"

signal damage_anim(color, num, pos)

enum STATES {
	TRACKING_PLAYER,
	SEARCHING,
	ATTACKING
}
var _current_state:int = STATES.SEARCHING

export(int) var melee_range = 7
export(float) var attack_speed = 1.0
export(bool) var is_ranged = false
export(float) var attack_range = 5.0
export(PackedScene) var ranged_attack_projectile

onready var _player = get_tree().get_nodes_in_group("player").front()
onready var _level = get_tree().get_nodes_in_group('level').front()

var _velocity:Vector3 = Vector3()
var _path:Array = []
var _last_facing_direction:Vector3 = Vector3.ZERO
var _can_attack:bool = true
export (NodePath) var attack_anim
onready var attack_animator = get_node(attack_anim)
export (NodePath) var walk_audio

func _ready():
	randomize()
	update_bars()
	$AttackTimer.wait_time = attack_speed
	
	SteamNetwork.register_rpcs(self,
		[
			["_apply_damage", SteamNetwork.PERMISSION.SERVER],
			["_tell_server_damage", SteamNetwork.PERMISSION.CLIENT_ALL],
			["_add_elemental_effects", SteamNetwork.PERMISSION.SERVER],
			["_tell_server_elemental_effects", SteamNetwork.PERMISSION.CLIENT_ALL],
			["_sync_state", SteamNetwork.PERMISSION.SERVER]
		]
	)


func _setup_network_enemy() -> void:
	$collision.disabled = true
	._setup_network_enemy()


func update_bars():
	$health_bar/Viewport/root.update_bars(max_health, health, max_armor, armor)
	if health <= 0: 
		$health_bar.visible = false
		

#Movement #############
func calculate_move_direction() -> Vector3:
	match _current_state:
		STATES.SEARCHING:
			return _handle_searching()
		STATES.TRACKING_PLAYER:
			return _handle_tracking_player()
		STATES.ATTACKING:
			return _handle_attacking()
		_: return Vector3.ZERO


func _handle_searching() -> Vector3:
	if _has_line_of_sight_to_player():
		move_state(STATES.TRACKING_PLAYER)
		return Vector3.ZERO
	
	if not _path.empty():
		var move_direction = _calculate_direction_to_next_path_point()
		_face_move_direction(move_direction)
		return move_direction
	else:
		_get_path()
		return Vector3.ZERO


func _handle_tracking_player() -> Vector3:
	if not _has_line_of_sight_to_player():
		_get_path()
		move_state(STATES.SEARCHING)
		return Vector3.ZERO
	return _calculate_direction_to_player()


func _handle_attacking() -> Vector3:
	if _can_attack:
		if _has_line_of_sight_to_player() and _distance_to_player() < attack_range:
			if attack_animator: 
				attack_animator.play("fire")
			else:
				_attack_player()
		else: move_state(STATES.TRACKING_PLAYER)
	return Vector3.ZERO


func _attack_player():
	if dead: return
	if not is_ranged:
		var distance = (_player.global_transform.origin - global_transform.origin).length()
		if distance < melee_range:
			_player.damage(10)
	else:
		var projectile = ranged_attack_projectile.instance()
		var direction_to_player:Vector3 = (_player.global_transform.origin - global_transform.origin).normalized() 
		get_parent().add_child(projectile)
		projectile.global_transform.origin = $MeshInstance/sprite_container/RangedOrigin.global_transform.origin
		projectile.fire_at(direction_to_player)
	$AttackTimer.start()
	_can_attack = false


func _calculate_direction_to_player() -> Vector3:
	var move_direction:Vector3 = _player.global_transform.origin - global_transform.origin 
	var distance_to_player = move_direction.length()
	if distance_to_player < attack_range:
		_current_state = STATES.ATTACKING
		return Vector3.ZERO
	else:
		move_direction.y = 0
		move_direction = move_direction.normalized()
		_face_move_direction(move_direction)
		return move_direction


func _get_path() -> void:
	_path = _level.calculate_path(global_transform.origin, _player.global_transform.origin)


func _calculate_direction_to_next_path_point() -> Vector3:
	var point:Vector3 = _path.front()
	
	if global_transform.origin.distance_to(point) < 1.7:
		_path.pop_front()
	
	return _calculate_direction_to_point(point)


func _calculate_direction_to_point(point:Vector3) -> Vector3:
	var direction:Vector3 = point - global_transform.origin
	direction.y = 0
	return direction.normalized()


func _face_move_direction(move_direction:Vector3) -> void:
	if move_direction != Vector3.ZERO:
		_last_facing_direction = lerp(_last_facing_direction, move_direction, 0.05)
		$MeshInstance.look_at(_last_facing_direction + global_transform.origin, Vector3.UP)
		$MeshInstance.rotation = Vector3(
			-PI/2,
			$MeshInstance.rotation.y + PI,
			0
		)
		$MeshInstance.orthonormalize()


func move_state(_state_in: int):
	if _current_state == _state_in: return
	_current_state = _state_in
	
	if NetworkHelper.is_multiplayer_is_host(): SteamNetwork.rpc_all_clients(self, "_sync_state", [_state_in])
	
	match _current_state:
		STATES.ATTACKING:
			$AnimationPlayer.stop()
		STATES.SEARCHING:
			$AnimationPlayer.play("walk")
		STATES.TRACKING_PLAYER:
			$AnimationPlayer.play("walk")


func _sync_state(server_id:int, new_state:int) -> void:
	if server_id == SteamNetwork._my_steam_id: return
	move_state(new_state)
#Movement #############


#Player Location Helpers #############
func _distance_to_player() -> float:
	return global_transform.origin.distance_to(_player.global_transform.origin)


func _has_line_of_sight_to_player() -> bool:
	$PlayerLineOfSight.enabled = true
	$PlayerLineOfSight.cast_to = _player.global_transform.origin - global_transform.origin
	$PlayerLineOfSight.force_raycast_update()
	if $PlayerLineOfSight.is_colliding():
		if $PlayerLineOfSight.get_collider().is_in_group('player'):
			return true
	$PlayerLineOfSight.enabled = false
	return false
#Player Location Helpers #############


#Damage #################
func damage(amount:int, knockback:Vector3 = Vector3.ZERO) -> void:
	if not NetworkHelper.is_multiplayer() :
		_apply_damage(-1, amount, knockback)
	elif SteamNetwork.is_server():
		SteamNetwork.rpc_all_clients(self, '_apply_damage', [amount, knockback])
	else:
		SteamNetwork.rpc_on_server(self, '_tell_server_damage',  [amount, knockback])
	


func _tell_server_damage(damage_dealer:int, amount:int, knockback:Vector3) -> void:
	SteamNetwork.rpc_all_clients(self, '_apply_damage', [amount, knockback])


func _apply_damage(server_id:int, amount:int, knockback:Vector3) -> void:
	if dead: return
	move_state(STATES.TRACKING_PLAYER)
	.damage(amount, knockback)
	update_bars()


# if the ammo has elemental effects apply them to the character
func apply_element(ammo_source):
	var elemental_damage:Array = [
		ammo_source.fire,
		ammo_source.frost,
		ammo_source.poison,
		ammo_source.bleed,
		[ammo_source.electric, ammo_source.electric_range, ammo_source.electric_jumps]
	]

	if not NetworkHelper.is_multiplayer() :
		_add_elemental_effects(-1, elemental_damage)
	elif SteamNetwork.is_server():
		SteamNetwork.rpc_all_clients(self, '_add_elemental_effects', [elemental_damage])
	else:
		SteamNetwork.rpc_on_server(self, '_tell_server_elemental_effects',  [elemental_damage])


func _tell_server_elemental_effects(damage_dealer:int, elemental_damage:Array) -> void:
	SteamNetwork.rpc_all_clients(self, '_add_elemental_effects', [elemental_damage])


func _add_elemental_effects(server_id:int, elemental_damage:Array):
	print(elemental_damage)
	if dead: return
	if elemental_damage[0]:
		$effect_handler.add_burn(elemental_damage[0])
	if elemental_damage[1]:
		$effect_handler.add_frost(elemental_damage[1])
	if elemental_damage[2]:
		$effect_handler.add_poison(elemental_damage[2])
	if elemental_damage[3]:
		$effect_handler.add_bleed(elemental_damage[3])
	if elemental_damage[4][0]:
		$effect_handler.add_electric(elemental_damage[4][0], elemental_damage[4][1], elemental_damage[4][2])


func poison_dmg(dmg):
	if dead: return
	$paudio.play(0)
	var post_armor_dmg = dmg
	if armor > 0:
		post_armor_dmg = post_armor_dmg * 0.5
	damage(post_armor_dmg)
	add_dmg_anim(Color.limegreen, post_armor_dmg, global_transform.origin)
	
func frost_dmg(dmg):
	if dead: return
	$faudio.play(0)
	var post_armor_dmg = dmg
	if armor > 0:
		post_armor_dmg = post_armor_dmg * 0.5
	damage(post_armor_dmg)
	add_dmg_anim(Color.skyblue, post_armor_dmg, global_transform.origin)

func bleed_dmg(dmg):
	if dead: return
	$baudio.play(0)
	var post_armor_dmg = dmg
	if armor > 0:
		post_armor_dmg = post_armor_dmg * 0.5
	damage(post_armor_dmg)
	add_dmg_anim(Color.red, post_armor_dmg, global_transform.origin)
	
func burn_dmg(dmg):
	if dead: return
	$buaudio.play(0)
	var post_armor_dmg = dmg
	if armor > dmg: post_armor_dmg = min(5 * post_armor_dmg, armor)
	damage(post_armor_dmg)
	add_dmg_anim(Color.orangered, post_armor_dmg, global_transform.origin)

func electric_dmg(dmg, max_distance, jumps):
	if dead: return
	$eaudio.play(0)
	var post_armor_dmg = dmg
	if armor > 0:
		post_armor_dmg = post_armor_dmg * 0.5
	damage(post_armor_dmg)
	add_dmg_anim(Color.yellow, post_armor_dmg, global_transform.origin)
	$effect_handler.start_electric_particle()
	jumps -= 1
	if jumps > 0:
		yield(get_tree().create_timer(0.05),"timeout")
		$effect_handler.add_electric(dmg, max_distance, jumps)

func explosion_dmg(dmg, knockback):
	if dead: return
	damage(dmg, knockback)
	add_dmg_anim(Color.white, dmg, global_transform.origin)
#Damage #################


func _on_death() -> void:
	dead = true
#	$MeshInstance/DetectionArea/CollisionShape.disabled = true
	$MeshInstance/sprite_container.rotation.y = 0
	for area in $MeshInstance/sprite_container.get_children():
		if area is Area: area.queue_free()
	$collision.disabled = true
	$effect_handler.die()
	$DeathPlayer.play("die")
	$deathburst.restart()
	if walk_audio:
		get_node(walk_audio).stop()
	loot_drop()
	

func loot_drop():
	var loot_val = randf()
	# 10% of the time drop a health pack
	if loot_val < 0.06:
		get_tree().get_nodes_in_group("col_spawner").front().add_health(global_transform.origin)
	elif loot_val < 0.1:
		get_tree().get_nodes_in_group("col_spawner").front().add_armor(global_transform.origin)
	elif loot_val < 0.2:
		get_tree().get_nodes_in_grodup("gam_spawner").front().add_ammo(global_transform.origin)

func _on_DeathPlayer_animation_finished(anim_name):
	if anim_name == "die":
		queue_free()


func _on_AttackTimer_timeout():
	_can_attack = true


func add_dmg_anim(color:Color, damage:int, global_position:Vector3) -> void:
	ParticleEventBus.request_particles(
		[ParticleEventBus.DAMAGE],
		global_position,
		{
			'norm': Vector3(0,1,0),
			'dmg': damage,
			'color': color,
			'crit': false
		}
	)
