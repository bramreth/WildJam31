extends Node


func is_multiplayer() -> bool:
	if SteamNetwork.get_server_steam_id() != -1: return true
	return false

func is_multiplayer_not_host() -> bool:
	if SteamNetwork.get_server_steam_id() != -1 and not SteamNetwork.is_server(): return true
	return false


func is_multiplayer_is_host() -> bool:
	if SteamNetwork.get_server_steam_id() != -1 and  SteamNetwork.is_server(): return true
	return false

#Deprecated ###################################################################
const DEFAULT_PORT:int = 2077
const MAX_PLAYERS:int = 4


signal player_joined(player_id, player_data)
signal player_left(player_id)
signal server_disconnected()
signal connected_to_server()
signal failed_to_connect_to_server()


var is_multiplayer:bool = false

var player_data:Dictionary = {}
# Info we send to other players
var my_data:Dictionary = { 'name': "username" }

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")


func host_server(port:int = DEFAULT_PORT) -> void:
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(port, MAX_PLAYERS)
	get_tree().network_peer = peer
	is_multiplayer = true


func join_server(ip:String, port:int = DEFAULT_PORT) -> void:
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, port)
	get_tree().network_peer = peer
	is_multiplayer = true


func _player_connected(id:int) -> void:
	# Called on both clients and server when a peer connects. Send my info to it.
	rpc_id(id, "register_player", my_data)


func _player_disconnected(id:int) -> void:
	player_data.erase(id) # Erase player from info.
	emit_signal("player_left", id)


func _connected_ok() -> void:
	emit_signal("connected_to_server")


func _server_disconnected() -> void:
	emit_signal("server_disconnected")
	is_multiplayer = false


func _connected_fail() -> void:
	emit_signal("failed_to_connect_to_server")
	is_multiplayer = false


remote func register_player(info:Dictionary) -> void:
	# Get the id of the RPC sender.
	var id = get_tree().get_rpc_sender_id()
	# Store the info
	player_data[id] = info
	
	emit_signal("player_joined", id, info)
