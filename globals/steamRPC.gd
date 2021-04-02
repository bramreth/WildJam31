extends Node

signal all_ready()

var network_players = {}
var pinging = false
var ping_time = 0
var debug = null
# Called when the node enters the scene tree for the first time.
func _ready():
	SteamNetwork.register_rpcs(self,
		[
			["client_has_shot",  SteamNetwork.PERMISSION.CLIENT_ALL],
			["shoot_event",  SteamNetwork.PERMISSION.SERVER],
			["client_has_reloaded",  SteamNetwork.PERMISSION.CLIENT_ALL],
			["reload_event",  SteamNetwork.PERMISSION.SERVER],
			["client_has_moved",  SteamNetwork.PERMISSION.CLIENT_ALL],
			["move_event",  SteamNetwork.PERMISSION.SERVER],
			["ping_recieved",  SteamNetwork.PERMISSION.CLIENT_ALL],
			["ping_reply",  SteamNetwork.PERMISSION.SERVER],
			["client_ready",  SteamNetwork.PERMISSION.CLIENT_ALL],
			["all_ready",  SteamNetwork.PERMISSION.SERVER],
			["client_particle",  SteamNetwork.PERMISSION.CLIENT_ALL],
			["particle_event",  SteamNetwork.PERMISSION.SERVER],
		]
	)
	
func _process(delta):
	if pinging:
		ping_time += delta
		
func notify_ready():
	SteamNetwork.rpc_on_server(self, 'client_ready', [])
	
var ready_peers = {}
var all_ready = false
	
func client_ready(id):
	for peer in SteamNetwork.get_peers():
		if not peer in ready_peers:
			ready_peers[peer] = false
		if peer == id:
			ready_peers[peer] = true
	for peer in ready_peers:
		if ready_peers[peer] == false:
			return
	SteamNetwork.rpc_on_client(id, self, "all_ready")
	all_ready = true
	
func all_ready(id):
	all_ready = true
	
func send_ping():
	pinging = true
	ping_time = 0
	SteamNetwork.rpc_on_server(self, 'ping_recieved', [])
	
func ping_recieved(id):
	if not all_ready: return
	SteamNetwork.rpc_on_client(id, self, "ping_reply")
	
func ping_reply(source):
	if debug:
		debug.push_ping(ping_time)
	else:
		debug = get_tree().get_nodes_in_group("debug_panel").front()
	pinging = false
	ping_time = 0
	
func tell_server_shot(rof, hit_loc, normal, ammo_name):
	if not all_ready: return
	SteamNetwork.rpc_on_server(self, 'client_has_shot', [rof, hit_loc, normal, ammo_name])
		
func tell_server_reload():
	if not all_ready: return
	SteamNetwork.rpc_on_server(self, 'client_has_reloaded', [])
	
func tell_server_moved(global_position:Vector3, rotation_y:float, rotation_z:float):
	if not all_ready: return
	SteamNetwork.rpc_on_server(self, 'client_has_moved', [global_position, rotation_y, rotation_z])
	
func client_has_shot(shooting_client, rof, hit_loc, normal, ammo_name):
	if not all_ready: return
	SteamNetwork.rpc_all_clients(self, 'shoot_event', [shooting_client, rof, hit_loc, normal, ammo_name])
	
func client_has_reloaded(client):
	if not all_ready: return
	SteamNetwork.rpc_all_clients(self, 'reload_event', [client])
	
func client_has_moved(moving_client, global_position, rotation_y, rotation_z):
	if not all_ready: return
	SteamNetwork.rpc_all_clients(self, 'move_event', [moving_client, global_position, rotation_y, rotation_z])
	
func shoot_event(server_id, shooting_client, rof, hit_loc, normal, ammo_name):
	if not all_ready: return
	if shooting_client == SteamLobby._my_steam_id: return
	get_or_init_client(shooting_client).shoot(rof, hit_loc, normal, ammo_name)
	
func reload_event(server_id, client):
	if not all_ready: return
	if client == SteamLobby._my_steam_id: return
	get_or_init_client(client).reload()
	
func move_event(server_id, moving_client, global_position:Vector3, rotation_y:float, rotation_z:float):
	if not all_ready: return
	if moving_client == SteamLobby._my_steam_id: return
	get_or_init_client(moving_client).update_position(global_position, rotation_y, rotation_z)

func get_or_init_client(client_id):
	if client_id in network_players:
		return network_players[client_id]
	for p in get_tree().get_nodes_in_group("network_player"):
			if p.name == str(client_id):
				network_players[client_id] = p
				return p
