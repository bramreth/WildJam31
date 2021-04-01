extends Node

var network_players = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	SteamNetwork.register_rpcs(self,
		[
			["client_has_shot",  SteamNetwork.PERMISSION.CLIENT_ALL],
			["shoot_event",  SteamNetwork.PERMISSION.SERVER],
			["client_has_moved",  SteamNetwork.PERMISSION.CLIENT_ALL],
			["move_event",  SteamNetwork.PERMISSION.SERVER],
		]
	)
	
func tell_server_shot(rof, spread):
	SteamNetwork.rpc_on_server(self, 'client_has_shot', [rof, spread])
	
func tell_server_moved(global_position:Vector3, rotation_y:float, rotation_z:float):
	SteamNetwork.rpc_on_server(self, 'client_has_moved', [global_position, rotation_y, rotation_z])
	
func client_has_shot(shooting_client, rof, spread):
	SteamNetwork.rpc_all_clients(self, 'shoot_event', [shooting_client, rof, spread])
	
func client_has_moved(moving_client, global_position, rotation_y, rotation_z):
	SteamNetwork.rpc_all_clients(self, 'move_event', [moving_client, global_position, rotation_y, rotation_z])
	
func shoot_event(server_id, shooting_client, rof, spread):
	if shooting_client == SteamLobby._my_steam_id: return
	get_or_init_client(shooting_client).shoot(rof, spread)
	
func move_event(server_id, moving_client, global_position:Vector3, rotation_y:float, rotation_z:float):
	if moving_client == SteamLobby._my_steam_id: return
	get_or_init_client(moving_client).update_position(global_position, rotation_y, rotation_z)

func get_or_init_client(client_id):
	if client_id in network_players:
		return network_players[client_id]
	for p in get_tree().get_nodes_in_group("network_player"):
			if p.name == str(client_id):
				network_players[client_id] = p
				return p
