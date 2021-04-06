extends RigidBody

const GRAVITY:float = -9.8
const SNAP_VECTOR:Vector3 = Vector3.DOWN*3

export(int) var max_health = 20
export(int) var max_armor = 0
onready var armor:int = max_armor
onready var health:int = max_health
var dead:bool = false

export(float) var jump_force = 16.0
export(float) var speed = 10.0
export(float) var sprint_speed_modifier = 1.5
export(float) var acceleration = 9.5

var velocity:Vector3 = Vector3.ZERO
var current_speed:float = speed
var input_direction:Vector3 = Vector3.ZERO
var current_snap:Vector3 = SNAP_VECTOR

var frost_speed_mod = 1.0

var _hang_time:float = 0.0

var fallg = 0

#Network Sync
var _target_global_pos:Vector3 = Vector3.ZERO
var _target_rotation_y:float = 0
var _target_rotation_z:float = 0

func _ready() -> void:
	SteamNetwork.register_rpcs(self,
		[
			["update_position", SteamNetwork.PERMISSION.CLIENT_ALL],
		]
	)
#	if NetworkHelper.is_multiplayer and not get_tree().is_network_server():
	if SteamNetwork.get_server_steam_id() != -1 and not SteamNetwork.is_server():
		_setup_network_enemy()


func _setup_network_enemy() -> void:
	mode = RigidBody.MODE_STATIC


func _integrate_forces(state):
	if state.linear_velocity.y < -50:
		fallg = state.linear_velocity.y
	elif fallg != 0 and state.linear_velocity.y > -50:
		damage(pow(abs(fallg)-50, 0.75))
		fallg = 0
	if state.linear_velocity.y < -200:
		state.linear_velocity.y = -200
		damage(1)
	apply_central_impulse(velocity * sqrt(clamp(1-(state.linear_velocity.length()/speed), 0, 1)))


func _physics_process(_delta: float) -> void:
	if dead: return
	
	if SteamNetwork.get_server_steam_id() == -1 :
		_handle_movement(_delta)
	elif SteamNetwork.is_server():
		_handle_movement(_delta)
		SteamNetwork.rpc_all_clients(self, 'update_position', [global_transform.origin, rotation.y, 0.0])
#		rpc('update_position', global_transform.origin, rotation.y, 0.0)
	else:
		_sync_position()
	
	


func _handle_movement(_delta:float) -> void:
	var hvel:Vector3 = velocity
	var move_direction:Vector3 = calculate_move_direction()
	hvel = hvel.linear_interpolate(move_direction * current_speed, acceleration * _delta)
	velocity.x = hvel.x
	
	velocity.z = hvel.z
	
	if is_running():
		current_speed = frost_speed_mod * speed * sprint_speed_modifier
	else: 
		current_speed = frost_speed_mod * speed


#Network syncing
func update_position(client_id: int, global_position:Vector3, rotation_y:float, rotation_z:float) -> void:
	_target_global_pos = global_position
	_target_rotation_y = rotation_y
	_target_rotation_z = rotation_z


func _sync_position() -> void:
	global_transform.origin = lerp(global_transform.origin, _target_global_pos, 0.5)
	rotation.y = lerp_angle(rotation.y, _target_rotation_y, 0.5)
	orthonormalize()
#End Network syncing


# region stubs
func calculate_move_direction() -> Vector3:
	return Vector3.ZERO
	
func is_running() -> bool:
	return false
#end region


func damage(amount:int, knockback:Vector3 = Vector3.ZERO) -> void:
	if dead: return
	
	if armor > 0:
		knockback /= 4
	if knockback:
		apply_central_impulse(knockback)
	
	if armor > 0:
		var armor_damage = amount
		amount = (armor - amount) * -1
		armor -= armor_damage
	if amount > 0:
		health = max(health - amount, 0)
		if health <= 0 and not dead:
			_on_death()

func _on_death() -> void:
	dead = true
	queue_free()
