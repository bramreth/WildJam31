extends Control

onready var lobby_players = get_node("lobby_members/lobby_players")
export (PackedScene) var lobby_player
var friends = []

signal notif(txt)

var _ready_players:Array = []
var origin = Vector2.ZERO
var tuck_point = Vector2.ZERO

export (NodePath) var wipe_path
export (NodePath) var button_path
var wipe = null
var play_button = null
var collapsed = true
var tuck_margin = 140
var full_margin = 440
# Called when the node enters the scene tree for the first time.
func _ready():
	wipe = get_node(wipe_path)
	play_button = get_node(button_path)
	randomize()
	SteamLobby.connect("lobby_joined", self, "_update_lobby")
	SteamLobby.connect("player_joined_lobby", self, "_update_lobby_from_player")
	SteamLobby.connect("player_left_lobby", self, "_update_lobby_from_player")
	SteamLobby.connect("lobby_join_requested", self, "_join_requested_lobby")
	$lobby_members/you.set_player(SteamLobby._my_steam_id)
	friends = get_friends()
	for fren in friends:
		var player = lobby_player.instance()
		$lobby_members/ScrollContainer/friends.add_child(player)
		player.set_player(fren)
		if player.state > 0:
			$lobby_members/ScrollContainer/friends.move_child(player, 0)
		player.name = str(fren)
		player.connect("join", self, "_join_requested_lobby")
		player.connect("invite", self, "_invite_by_id")
	for child in $lobby_members/ScrollContainer/friends.get_children():
		if child.in_game:
			$lobby_members/ScrollContainer/friends.move_child(child, 0)
	for x in range(3):
		var player = lobby_player.instance()
		lobby_players.add_child(player)
		player.in_lobby()
	SteamLobby.connect("lobby_created", self, "_on_lobby_created")
	SteamNetwork.register_rpcs(self,
		[
			["register_ready_player", SteamNetwork.PERMISSION.CLIENT_ALL],
			["update_ready_players", SteamNetwork.PERMISSION.SERVER],
			["_update_bg", SteamNetwork.PERMISSION.SERVER],
			["start_game", SteamNetwork.PERMISSION.SERVER],
		]
	)
	create_lobby()
	
#func update_dim(dim):
#	rect_size.y = dim.y

func _join_requested_lobby(lobby_id):
	SteamLobby.leave_lobby()
	SteamLobby.join_lobby(lobby_id)

func _update_lobby_from_player(steam_id):
	_update_lobby(SteamLobby._steam_lobby_id)

func _update_lobby(_steam_lobby_id):
	if SteamNetwork.get_peers().size() == 1:
		play_button.set_text("play")
	else:
		play_button.set_text("ready up")
	var members = []
	for member in SteamLobby.get_lobby_members():
		members.append(member)
	get_node("lobby_members/party_count").text = "Party (" + str(len(members)) +"/4)"
	for player_index in range(lobby_players.get_child_count()):
		
		if len(members) > player_index and members[player_index] != SteamLobby._my_steam_id:
			
			lobby_players.get_child(player_index).set_player(members[player_index], true)
		else:
			lobby_players.get_child(player_index).set_player(null)
			
	# hide lobby pals
	var idlist = []
	for child in $lobby_members/lobby_players.get_children():
		idlist.append(child.uid)
	for child in $lobby_members/ScrollContainer/friends.get_children():
		if child.uid in idlist:
			child.visible = false
		else:
			child.visible = true
			
func _invite_by_id(friend_id):
	Steam.inviteUserToLobby(SteamLobby._steam_lobby_id, friend_id)
	
func _on_lobby_created(lobby_id):
	_update_lobby(lobby_id)
	print(lobby_id)

func _on_invite_pressed():
	if SteamLobby.in_lobby():
		#pop up invite
		Steam.activateGameOverlayInviteDialog(SteamLobby.get_lobby_id())


func _on_ready_pressed():
	SteamNetwork.rpc_on_server(self, 'register_ready_player', [SteamNetwork._my_steam_id])
	print("ready pressed")

func get_friends():
	var flist = []
	for i in range(Steam.getFriendCount()):
		flist.append(Steam.getFriendByIndex(i, 4))
	return flist

func register_ready_player(caller:int, steam_id:int) -> void:
	if not _ready_players.has(steam_id):
		_ready_players.append(steam_id)
		print('READY: ' + String(steam_id))
		SteamNetwork.rpc_all_clients(self, 'update_ready_players', [_ready_players])
		if len(_ready_players) == len(SteamNetwork.get_peers().keys()):
			host_begin_countdown()

func host_begin_countdown():
	var msgs = ["game starting", "3", "2", "1"]
	while msgs:
		var m = msgs.pop_front()
		SteamNetwork.rpc_all_clients(self, '_update_bg', [m])
		yield(get_tree().create_timer(1), "timeout")
	SteamNetwork.rpc_all_clients(self, 'start_game')
	
func _update_bg(caller:int, m: String):
	emit_signal("notif", str(m))
	
func start_game(caller:int):
	# TODO start the game
	emit_signal("notif", str("go"))
	wipe.play("dip_to_black")
	yield(wipe, "animation_finished")
	Scene.change(Scene.STEAM_MULTIPLAYER)
	

func update_ready_players(caller:int, ready_players:Array) -> void:
	_ready_players = ready_players
	print('READY PLAYERS: ' + String(_ready_players))
	for p in _ready_players:
		if p == SteamLobby._my_steam_id:
			$lobby_members/you.set_ready()
	for lp in lobby_players.get_children():
		for p in _ready_players:
			if p == lp.uid:
				lp.set_ready()

func _input(event):
	if event.is_action_pressed("steam_debug"):
		print('STEAMNETWORK Peers: ' + String(SteamNetwork.get_peers()))
		print('STEAMNETWORK Server: ' + String(SteamNetwork.get_server_peer().steam_id))
		print('STEAMNETWORK Server Steam ID: ' + String(SteamNetwork.get_server_steam_id()))
		print('STEAMLOBBY Peers: ' + String(SteamLobby.get_lobby_members()))
		print('STEAMLOBBY Owner Steam ID: ' + String(SteamLobby.get_owner()))
		

func create_lobby():
	SteamLobby.leave_lobby()
	SteamLobby.create_lobby(Steam.LOBBY_TYPE_FRIENDS_ONLY, 4)


func expand():
	collapsed = false
	for m in get_tree().get_nodes_in_group("lobby_profile"):
		m.expand()
	$lobby_members.rect_size.x = 440
	$lobby_members/lobby_players.columns = 3
#	$lobby_members/chat.visible = false
#	$lobby_members/invite.visible = true
	

func collapse():
	collapsed = true
	for m in get_tree().get_nodes_in_group("lobby_profile"):
		m.collapse()
	$lobby_members.rect_size.x = 140
	$lobby_members/lobby_players.columns = 1
#	$lobby_members/chat.visible = false
#	$lobby_members/invite.visible = false
	

func _on_CurveTween_curve_tween(sat):
	margin_left = sat


func _on_play_on_pressed():
	SteamNetwork.rpc_on_server(self, 'register_ready_player', [SteamNetwork._my_steam_id])
