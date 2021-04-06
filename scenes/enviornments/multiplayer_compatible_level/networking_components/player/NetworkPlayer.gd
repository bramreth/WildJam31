extends Spatial
#class_name NetworkPlayer

var player_name:String = ''

var _target_global_pos:Vector3 = Vector3.ZERO
var _target_rotation_y:float = 0
var _target_rotation_x:float = 0


func _ready() -> void:
	_target_global_pos = global_transform.origin
#	_set_player_name()
#	NetworkHelper.connect("player_left", self, "_remove_player")


func _set_player_name() -> void:
	var player_name:String = Steam.getPlayerNickname(int(name))
	if player_name == null: player_name = Steam.getFriendPersonaName(int(name))
	$Viewport/Label.text = player_name


func _remove_player(player_id:int) -> void:
	if int(name) == player_id: queue_free()


func update_position(global_position:Vector3, rotation_y:float, rotation_x:float) -> void:
	_target_global_pos = global_position
	_target_rotation_y = rotation_y
	_target_rotation_x = rotation_x


func shoot(rof, hit_loc, normal, ammo_name) -> void:
	$GunRig.shoot(rof)
	ParticleEventBus.request_particles(
			[ParticleEventBus.HIT, ParticleEventBus.CLOUD], 
			hit_loc, 
			{'norm': normal}
			)
	
	ParticleEventBus.request_particles(
			[ParticleEventBus.SPRITE],
			hit_loc, 
			{
				'norm': normal,
				'icon': get_tree().get_nodes_in_group("player_ammo").front().get_icon_by_name(ammo_name)
			}
			)


func reload() -> void:
	$GunRig.reload()


func _physics_process(delta:float) -> void:
	_sync_position()
	_scale_nameplate()



func _sync_position() -> void:
	global_transform.origin = lerp(global_transform.origin, _target_global_pos, 0.5)
	rotation.y = lerp_angle(rotation.y, _target_rotation_y, 0.5)
	$GunRig.rotation.z = lerp_angle($GunRig.rotation.x, _target_rotation_x, 0.5)
	orthonormalize()
	$GunRig.orthonormalize()


func _scale_nameplate() -> void:
	var camera:Camera = get_tree().get_nodes_in_group('player_camera').front()
	var dist:float = camera.global_transform.origin.distance_to(global_transform.origin) * 0.1
	$NamePlate.scale = Vector3(dist, dist, dist)
