extends "res://scenes/characters/character.gd"

signal damage_anim(color, num, pos)

enum STATES {
	IDLE,
	TRACKING_PLAYER,
	SEARCHING
}
var _current_state:int = STATES.IDLE

onready var _player = get_tree().get_nodes_in_group("player").front()
onready var _level = get_tree().get_nodes_in_group('level').front()

var _velocity:Vector3 = Vector3()
var _path:Array = []
var _last_facing_direction:Vector3 = Vector3.ZERO

func _ready():
	update_bars()

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
		_: return Vector3.ZERO


func _calculate_direction_to_player() -> Vector3:
	var move_direction:Vector3 = _player.global_transform.origin - global_transform.origin 
	var distance_to_player = move_direction.length()
	if distance_to_player < 4:
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
	if armor <= 0:
		if ammo_source.frost:
			$effect_handler.add_frost(ammo_source.frost)
		if ammo_source.poison:
			$effect_handler.add_poison(ammo_source.poison)
		if ammo_source.bleed:
			$effect_handler.add_bleed(ammo_source.bleed)
	
		
func poison_dmg(dmg):
	if dead: return
	damage(dmg)
	_player.add_dmg_anim(Color.limegreen, dmg, global_transform.origin)
	
func frost_dmg(dmg):
	if dead: return
	damage(dmg)
	_player.add_dmg_anim(Color.skyblue, dmg, global_transform.origin)

func bleed_dmg(dmg):
	if dead: return
	damage(dmg)
	_player.add_dmg_anim(Color.red, dmg, global_transform.origin)
	
func burn_dmg(dmg):
	if dead: return
	var post_armor_dmg = dmg
	if armor > dmg: post_armor_dmg = min(5 * post_armor_dmg, armor)
	damage(post_armor_dmg)
	_player.add_dmg_anim(Color.orangered, post_armor_dmg, global_transform.origin)

func _on_death() -> void:
	dead = true
	$MeshInstance/DetectionArea/CollisionShape.disabled = true
	$Hitbox/CollisionShape.disabled = true
	$collision.disabled = true
	$effect_handler.die()
	$DeathPlayer.play("die")
	$deathburst.restart()


func _on_DeathPlayer_animation_finished(anim_name):
	if anim_name == "die":
		queue_free()
