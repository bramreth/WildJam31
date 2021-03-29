extends Spatial


var _target_global_pos:Vector3 = Vector3.ZERO
var _target_rotation_y:float = 0
var _target_rotation_z:float = 0


func _ready() -> void:
	NetworkHelper.connect("player_left", self, "_remove_player")


func _remove_player(player_id:int) -> void:
	if int(name) == player_id: queue_free()


remote func update_position(global_position:Vector3, rotation_y:float, rotation_z:float) -> void:
	_target_global_pos = global_position
	_target_rotation_y = rotation_y
	_target_rotation_z = rotation_z


remote func shoot() -> void:
	pass


func _physics_process(delta:float) -> void:
	global_transform.origin = lerp(global_transform.origin, _target_global_pos, delta)
	rotation.y = lerp_angle(rotation.y, _target_rotation_y, delta)
	$GunRig.rotation.z = lerp_angle($GunRig.rotation.z, _target_rotation_z, delta)
	orthonormalize()
	$GunRig.orthonormalize()
