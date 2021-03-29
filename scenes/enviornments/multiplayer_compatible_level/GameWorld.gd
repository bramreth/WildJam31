extends Spatial

onready var players = $Players
onready var network_player:PackedScene = load("res://scenes/enviornments/multiplayer_compatible_level/NetworkPlayer.tscn")

func _ready() -> void:
	if NetworkHelper.is_multiplayer:
		players.get_child(0).name  = String(get_tree().get_network_unique_id()) #Sets the local player's node name to their network ID
		_setup_multiplayer()
		


#Network logic
func _setup_multiplayer() -> void:
	NetworkHelper.connect("player_joined", self, "_spawn_player")
	NetworkHelper.connect("server_disconnected", self, "_server_disconnected")
	for player_id in NetworkHelper.player_data.keys():
			_spawn_player(player_id, NetworkHelper.player_data[player_id])


func _spawn_player(player_id:int, player_data:Dictionary) -> void:
	var new_player = network_player.instance()
	new_player.name = String(player_id)
	players.add_child(new_player)
