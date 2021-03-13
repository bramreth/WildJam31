extends "res://scenes/characters/character.gd"

enum STATES {
	IDLE,
	TRACKING_PLAYER,
	SEARCHING
}
var _current_state:int = STATES.IDLE


onready var _player = get_tree().get_nodes_in_group("player").front()
onready var _level:Level = owner as Level

var _velocity:Vector3 = Vector3()
var _path:Array = []

func _ready() -> void:
	print(_level.name)


func _physics_process(delta:float) -> void:
	_velocity = _calculate_move_direction(_velocity)
	_velocity *= speed
	_velocity.y += GRAVITY
	_velocity = move_and_slide(_velocity, Vector3.UP)


func _calculate_move_direction(vel:Vector3) -> Vector3:
	match _current_state:
		STATES.IDLE: 
			if randf() > 0.95:
				print(name + 'is now roaming')
				_current_state = STATES.SEARCHING
				_get_path()
			return Vector3.ZERO
		STATES.SEARCHING:
			if not _path.empty():
				var move_direction = _calculate_direction_to_next_path_point()
		#		_face_move_direction(move_direction)
				return move_direction
			else:
				print(name + 'is now idle')
				_current_state = STATES.IDLE
				return Vector3.ZERO
		STATES.TRACKING_PLAYER:
			return _calculate_direction_to_player()
		_: return Vector3.ZERO


func _calculate_direction_to_player() -> Vector3:
	var move_direction:Vector3 = _player.global_transform.origin - global_transform.origin 
	var distance_to_player = move_direction.length()
	move_direction.y = 0
	move_direction = move_direction.normalized()
	
#	_face_move_direction(move_direction)
	return move_direction
#	if distance_to_player > 10:
#		return move_direction
#	elif distance_to_player < 5:
#		return -move_direction
#	else: return Vector3.ZERO


func _get_path() -> void:
	_path = _level.calculate_path(global_transform.origin, Vector3(rand_range(-40,40), 0, rand_range(-40,40)))


func _calculate_direction_to_next_path_point() -> Vector3:
	var point:Vector3 = _path.front()
	
	if global_transform.origin.distance_to(point) < 1:
		_path.pop_front()
	
	return _calculate_direction_to_point(point)


func _calculate_direction_to_point(point:Vector3) -> Vector3:
	var direction:Vector3 = point - global_transform.origin
	direction.y = 0
	return direction.normalized()
