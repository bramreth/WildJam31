extends Spatial

onready var navigation:Navigation = $Navigation


func calculate_path(start_pos:Vector3, end_pos:Vector3) -> Array:
	var path:PoolVector3Array = navigation.get_simple_path(start_pos, end_pos)
	var path_array:Array = path
	path_array.pop_front()
	return path_array
