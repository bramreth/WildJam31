extends Node

var network_players = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	SteamNetwork.register_rpcs(self,
		[
			["client_has_shot",  SteamNetwork.PERMISSION.CLIENT_ALL],
			["shoot_event",  SteamNetwork.PERMISSION.SERVER],
		]
	)
	
func tell_server_shot(rof, spread):
	SteamNetwork.rpc_on_server(self, 'client_has_shot', [rof, spread])
	
remote func client_has_shot(shooting_client, rof, spread):
	SteamNetwork.rpc_all_clients(self, 'shoot_event', [shooting_client, rof, spread])
	
remote func shoot_event(server_id, shooting_client, rof, spread):
	if shooting_client == server_id: return
	get_or_init_client(shooting_client).shoot(rof, spread)

func get_or_init_client(client_id):
	if client_id in network_players:
		return network_players[client_id]
	for p in get_tree().get_nodes_in_group("network_player"):
			if p.name == str(client_id):
				network_players[client_id] = p
				return p
