extends Spatial

onready var players = $Players
onready var network_player:PackedScene = load("res://scenes/enviornments/multiplayer_compatible_level/NetworkPlayer.tscn")
onready var local_player:KinematicBody = players.get_child(0)

func _ready() -> void:
	randomize()
	if true:#NetworkHelper.is_multiplayer:
		players.get_child(0).name  = String(get_tree().get_network_unique_id()) #Sets the local player's node name to their network ID
		_setup_multiplayer()
		if get_tree().is_network_server(): _move_player_to_spawn_position(local_player)
		else: rpc_id(1, 'request_respawn')
	else:
		_move_player_to_spawn_position(local_player)


#Network logic
func _setup_multiplayer() -> void:
	NetworkHelper.connect("player_joined", self, "_spawn_network_player")
	NetworkHelper.connect("server_disconnected", self, "_server_disconnected")
	for player_id in SteamNetwork.get_peers():
			if SteamLobby._my_steam_id != player_id:
				_spawn_network_player(player_id)


func _spawn_network_player(player_id:int) -> void:
	var new_player = network_player.instance()
	new_player.name = String(Steam.getFriendPersonaName(player_id))
	players.add_child(new_player)
	if SteamNetwork.is_server():
		_move_player_to_spawn_position(new_player)


func _move_player_to_spawn_position(player) -> void:
	var spawn = $Spawns.get_children()[randi() % $Spawns.get_child_count()]
	player.global_transform = spawn.global_transform
	player.global_transform.origin.y += 2


remote func request_respawn() -> void:
	var player_id:int = get_tree().get_rpc_sender_id()
	var player = players.get_node(String(player_id))
	
	_move_player_to_spawn_position(player)
	player.rpc_id(player_id, 'server_update_transform', player.global_transform)
