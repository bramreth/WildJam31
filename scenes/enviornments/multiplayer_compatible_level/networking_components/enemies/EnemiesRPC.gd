extends Node

signal wave_started(wave_number)
signal wave_ended()

onready var trash = $Trash
onready var fast = $Fast
onready var ranged = $Ranged
onready var tank = $Tank
onready var spawn_timer:Timer = $Timer
var spawners

export var trash_mob_scene:PackedScene
export var fast_mob_scene:PackedScene
export var ranged_mob_scene:PackedScene
export var tank_mob_scene:PackedScene


var current_wave:int = 1


func _ready():
	SteamRpc.connect("all_ready", self, "all_players_ready")
	spawners = get_tree().get_nodes_in_group('spawner')
	SteamNetwork.register_rpcs(self,
		[
			["_server_start_wave", SteamNetwork.PERMISSION.CLIENT_ALL],
		]
	)


func all_players_ready() -> void:
	$Timer.start(3)


func next_wave() -> void:
	if not NetworkHelper.is_multiplayer():
		_start_wave()
	elif NetworkHelper.is_multiplayer_is_host():
		SteamNetwork.rpc_all_clients(self, '_server_start_wave', [current_wave])


func _server_start_wave(server_id:int, current_wave:int) -> void:
	self.current_wave = current_wave
	_start_wave()


func _start_wave() -> void:
	emit_signal('wave_started', current_wave)


func _on_Timer_timeout():
	next_wave()
