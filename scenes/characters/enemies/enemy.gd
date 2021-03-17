extends "res://scenes/characters/character.gd"

signal damage_anim(color, num, pos)

enum STATES {
	IDLE,
	TRACKING_PLAYER,
	SEARCHING,
	ATTACKING
}
var _current_state:int = STATES.IDLE

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

func _ready():
	update_bars()
	$AttackTimer.wait_time = attack_speed

func update_bars():
	$health_bar/Viewport/root/HealthBar.max_value = max_health
	$health_bar/Viewport/root/HealthBar.value = health
	$health_bar/Viewport/root/HealthBar/health.text = str(health)
	$health_bar/Viewport/root/ArmorBar.max_value = max_armor
	$health_bar/Viewport/root/ArmorBar.value = armor
	$health_bar/Viewport/root/ArmorBar/armor.text = str(armor)
	if armor <= 0: 
		$health_bar/Viewport/root/ArmorBar.visible = false
	if health <= 0: 
		$health_bar/Viewport/root/HealthBar.visible = false
		

func calculate_move_direction() -> Vector3:
	match _current_state:
		STATES.IDLE: 
			return Vector3.ZERO
		STATES.SEARCHING:
			if not _path.empty():
				var move_direction = _calculate_direction_to_next_path_point()
				_face_move_direction(move_direction)
				return move_direction
			else:
				if not _has_line_of_sight_to_player():
					move_state(STATES.IDLE)
					return Vector3.ZERO
				else:
					move_state(STATES.TRACKING_PLAYER)
					return Vector3.ZERO
		STATES.TRACKING_PLAYER:
			if not _has_line_of_sight_to_player():
				_get_path()
				move_state(STATES.SEARCHING)
			return _calculate_direction_to_player()
		STATES.ATTACKING:
			if _can_attack:
				if _has_line_of_sight_to_player() and _distance_to_player() < attack_range:
					_attack_player()
				else: move_state(STATES.TRACKING_PLAYER)
			return Vector3.ZERO
		_: return Vector3.ZERO


func _attack_player():
	if not is_ranged:
		_player.damage(10)
	else:
		var projectile = ranged_attack_projectile.instance()
		var direction_to_player:Vector3 = _calculate_direction_to_point(_player.global_transform.origin)
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


func detected_body(body:KinematicBody):
	if not body: return
	if body.is_in_group('player') and _has_line_of_sight_to_player():
		_path.clear()
		move_state(STATES.TRACKING_PLAYER)


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

func move_state(_state_in: int):
#	assert(_state_in in STATES.keys(), "invalid target state")
	if _current_state == _state_in: return
	_current_state = _state_in
	match _current_state:
		STATES.IDLE:
			$AnimationPlayer.stop()
		STATES.ATTACKING:
			$AnimationPlayer.stop()
		STATES.SEARCHING:
			$AnimationPlayer.play("walk")
		STATES.TRACKING_PLAYER:
			$AnimationPlayer.play("walk")
	


func damage(amount:int, knockback:Vector3 = Vector3.ZERO) -> void:
	if dead: return
	move_state(STATES.TRACKING_PLAYER)
	.damage(amount, knockback)
	update_bars()

# if the ammo has elemental effects apply them to the character
func apply_element(ammo_source):
	if dead: return
	if ammo_source.fire:
		$effect_handler.add_burn(ammo_source.fire)
	if ammo_source.frost:
		$effect_handler.add_frost(ammo_source.frost)
	if ammo_source.poison:
		$effect_handler.add_poison(ammo_source.poison)
	if ammo_source.bleed:
		$effect_handler.add_bleed(ammo_source.bleed)
	if  ammo_source.electric:
		$effect_handler.add_electric(ammo_source.electric, ammo_source.electric_range, ammo_source.electric_jumps)
	
		
func poison_dmg(dmg):
	if dead: return
	var post_armor_dmg = dmg
	if armor > 0:
		post_armor_dmg = post_armor_dmg * 0.5
	damage(post_armor_dmg)
	_player.add_dmg_anim(Color.limegreen, post_armor_dmg, global_transform.origin)
	
func frost_dmg(dmg):
	if dead: return
	var post_armor_dmg = dmg
	if armor > 0:
		post_armor_dmg = post_armor_dmg * 0.5
	damage(post_armor_dmg)
	_player.add_dmg_anim(Color.skyblue, post_armor_dmg, global_transform.origin)

func bleed_dmg(dmg):
	if dead: return
	var post_armor_dmg = dmg
	if armor > 0:
		post_armor_dmg = post_armor_dmg * 0.5
	damage(post_armor_dmg)
	_player.add_dmg_anim(Color.red, post_armor_dmg, global_transform.origin)
	
func burn_dmg(dmg):
	if dead: return
	var post_armor_dmg = dmg
	if armor > dmg: post_armor_dmg = min(5 * post_armor_dmg, armor)
	damage(post_armor_dmg)
	_player.add_dmg_anim(Color.orangered, post_armor_dmg, global_transform.origin)

func electric_dmg(dmg, max_distance, jumps):
	if dead: return
	var post_armor_dmg = dmg
	if armor > 0:
		post_armor_dmg = post_armor_dmg * 0.5
	damage(post_armor_dmg)
	_player.add_dmg_anim(Color.yellow, post_armor_dmg, global_transform.origin)
	$effect_handler.start_electric_particle()
	jumps -= 1
	if jumps > 0:
		yield(get_tree().create_timer(0.05),"timeout")
		$effect_handler.add_electric(dmg, max_distance, jumps)

func _on_death() -> void:
	dead = true
	$MeshInstance/DetectionArea/CollisionShape.disabled = true
	$MeshInstance/sprite_container.rotation.y = 0
	for area in $MeshInstance/sprite_container.get_children():
		if area is Area: area.queue_free()
	$collision.disabled = true
	$effect_handler.die()
	$DeathPlayer.play("die")
	$deathburst.restart()


func _on_DeathPlayer_animation_finished(anim_name):
	if anim_name == "die":
		queue_free()


func _on_AttackTimer_timeout():
	_can_attack = true
