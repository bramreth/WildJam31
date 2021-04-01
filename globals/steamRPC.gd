extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	SteamNetwork.register_rpcs(self,
		[
			["shooter",  SteamNetwork.PERMISSION.CLIENT_ALL],
			["client_shot",  SteamNetwork.PERMISSION.SERVER],
		]
	)
	
func shoot_server():
	SteamNetwork.rpc_on_server(self, 'shooter', [])
	
func shoot_client(shooting_client):
	SteamNetwork.rpc_all_clients(self, 'shoot', [shooting_client])
	
remote func shooter(id):
	shoot_client(id)
