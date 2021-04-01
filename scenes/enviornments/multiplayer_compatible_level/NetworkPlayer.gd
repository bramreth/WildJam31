extends Spatial
#class_name NetworkPlayer

var player_name:String = ''

var _target_global_pos:Vector3 = Vector3.ZERO
var _target_rotation_y:float = 0
var _target_rotation_z:float = 0


func _ready() -> void:
	_target_global_pos = global_transform.origin
	
#	NetworkHelper.connect("player_left", self, "_remove_player")


func _remove_player(player_id:int) -> void:
	if int(name) == player_id: queue_free()


remote func update_position(sender_id: int, global_position:Vector3, rotation_y:float, rotation_z:float) -> void:
	_target_global_pos = global_position
	_target_rotation_y = rotation_y
	_target_rotation_z = rotation_z


remote func shoot() -> void:
	pass


func _physics_process(delta:float) -> void:
	_sync_position()
	_scale_nameplate()
	


func _sync_position() -> void:
	global_transform.origin = lerp(global_transform.origin, _target_global_pos, 0.5)
	rotation.y = lerp_angle(rotation.y, _target_rotation_y, 0.5)
	$GunRig.rotation.z = lerp_angle($GunRig.rotation.z, _target_rotation_z, 0.5)
	orthonormalize()
	$GunRig.orthonormalize()


func _scale_nameplate() -> void:
	var camera:Camera = get_tree().get_nodes_in_group('player_camera').front()
	var dist:float = camera.global_transform.origin.distance_to(global_transform.origin) * 0.1
	$NamePlate.scale = Vector3(dist, dist, dist)
