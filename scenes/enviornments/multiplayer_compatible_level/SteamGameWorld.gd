extends Spatial

onready var players = $Players
onready var network_player:PackedScene = load("res://scenes/enviornments/multiplayer_compatible_level/NetworkPlayer.tscn")
onready var local_player:KinematicBody = players.get_child(0)
export (bool) var debug
export(Resource) var level_env
export(Resource) var reward_env

func _ready() -> void:
	Game.debug = debug
	randomize()
	Event.connect(Event.START_WAVE, self, "start_wave")
	Event.connect(Event.WARP, self, "goto_reward")
	Event.connect(Event.RESPAWN, self, "respawn")
	SteamRpc.notify_ready()
	
	if true:#NetworkHelper.is_multiplayer:
		players.get_child(0).name  = String(SteamLobby._my_steam_id) #Sets the local player's node name to their network ID
		_setup_multiplayer()
		if SteamNetwork.is_server(): _move_player_to_spawn_position(local_player)
#		else: rpc_id(1, 'request_respawn')
	else:
		_move_player_to_spawn_position(local_player)

func start_wave():
	pass
	
func goto_reward():
	$RewardRoom.goto_reward(true)
	$WorldEnvironment.environment = reward_env
	local_player.global_transform = $RewardRoom.get_reward_spawn()
	$Level.visible = false
	$RewardRoom.visible = true
	
func respawn():
	$WorldEnvironment.environment = level_env
	local_player.global_transform = $Spawns.get_children()[randi() % $Spawns.get_child_count()].global_transform
	local_player.global_transform.origin.y += 2
	$Level.visible = true
	$RewardRoom.visible = false

#Network logic
func _setup_multiplayer() -> void:
	for player_id in SteamNetwork.get_peers():
			if SteamLobby._my_steam_id != player_id:
				_spawn_network_player(player_id)


func _spawn_network_player(player_id:int) -> void:
	var new_player = network_player.instance()
	new_player.name = String(player_id)#Steam.getFriendPersonaName(player_id)
	players.add_child(new_player)
	if SteamNetwork.is_server():
		_move_player_to_spawn_position(new_player)


func _move_player_to_spawn_position(player) -> void:
	var spawn = $Spawns.get_children()[randi() % $Spawns.get_child_count()]
	player.global_transform = spawn.global_transform
	player.global_transform.origin.y += 2


remote func request_respawn() -> void:
	var player = players.get_node(String(SteamLobby._my_steam_id))
	_move_player_to_spawn_position(player)
