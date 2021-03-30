extends Control

onready var root = get_node("MarginContainer/menu_root")
onready var lobby_players = root.get_node("lobby_members/lobby_players/")
export (PackedScene) var lobby_player
var friends = []
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	SteamLobby.connect("lobby_joined", self, "_update_lobby")
	SteamLobby.connect("player_joined_lobby", self, "_update_lobby_from_player")
	SteamLobby.connect("player_left_lobby", self, "_update_lobby_from_player")

	for x in range(3):
		var player = lobby_player.instance()
		lobby_players.add_child(player)
	SteamLobby.connect("lobby_created", self, "_on_lobby_created")
	SteamLobby.create_lobby(Steam.LOBBY_TYPE_FRIENDS_ONLY, 4)

func _update_lobby_from_player(steam_id):
	_update_lobby(SteamLobby._steam_lobby_id)

func _update_lobby(_steam_lobby_id):
	var members = []
	for member in SteamLobby.get_lobby_members():
		members.append(member)
	root.get_node("lobby_members/party_count").text = "Party (" + str(len(members)) +"/4)"
	for player_index in range(lobby_players.get_child_count()):
		
		if len(members) > player_index:
			lobby_players.get_child(player_index).set_player(members[player_index])
		else:
			lobby_players.get_child(player_index).set_player(null)

func get_friends():

	var flist = []
	for i in range(Steam.getFriendCount()):
		flist.append(Steam.getFriendByIndex(i, 4))
	return flist
	
func filter_friends():
	var flist = get_friends()
	var new_flist = []
	for f in flist:
		if Steam.getFriendPersonaName(f) in ["sucubutplug", "SuperFryGuy", "eggsavior", "Darkmax"]:
			new_flist.append(f)
	return new_flist

	
func _on_lobby_created(lobby_id):
	_update_lobby(lobby_id)
	print(lobby_id)


func _on_invite_pressed():
	if SteamLobby.in_lobby():
		#pop up invite
		Steam.activateGameOverlayInviteDialog(SteamLobby.get_lobby_id())


func _on_ready_pressed():
	print("ready pressed")
