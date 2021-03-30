extends Spatial

onready var players = $Players
onready var network_player:PackedScene = load("res://scenes/enviornments/multiplayer_compatible_level/NetworkPlayer.tscn")
onready var local_player:KinematicBody = players.get_child(0)

func _ready() -> void:
	_move_player_to_spawn_position(local_player)
	if NetworkHelper.is_multiplayer:
		players.get_child(0).name  = String(get_tree().get_network_unique_id()) #Sets the local player's node name to their network ID
		_setup_multiplayer()
		


#Network logic
func _setup_multiplayer() -> void:
	NetworkHelper.connect("player_joined", self, "_spawn_player")
	NetworkHelper.connect("server_disconnected", self, "_server_disconnected")
	for player_id in NetworkHelper.player_data.keys():
			_spawn_network_player(player_id, NetworkHelper.player_data[player_id])


func _spawn_network_player(player_id:int, player_data:Dictionary) -> void:
	var new_player = network_player.instance()
	new_player.name = String(player_id)
	players.add_child(new_player)
	_move_player_to_spawn_position(new_player)


func _move_player_to_spawn_position(player) -> void:
	player.global_transform = $PlayerSpawn.global_transform
	player.global_transform.origin.y += 2
	
	if player is NetworkPlayer:
		player.rpc('server_update_transform', player.global_transform)
