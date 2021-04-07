extends Node

signal wave_started(wave_number)
signal wave_ended()

onready var trash = $Trash
onready var fast = $Fast
onready var ranged = $Ranged
onready var tank = $Tank
onready var spawn_timer:Timer = $Timer
var spawners:Array

export var trash_mob_scene:PackedScene
export var fast_mob_scene:PackedScene
export var ranged_mob_scene:PackedScene
export var tank_mob_scene:PackedScene


var current_wave:int = 0
var current_wave_mobs:Dictionary = {}


func _ready():
	SteamRpc.connect("all_ready", self, "all_players_ready")
	spawners = get_tree().get_nodes_in_group('spawner')
	SteamNetwork.register_rpcs(self,
		[
			["_server_start_wave", SteamNetwork.PERMISSION.CLIENT_ALL],
			["_server_spawn_enemy", SteamNetwork.PERMISSION.CLIENT_ALL]
		]
	)


func all_players_ready() -> void:
	$Timer.start(3)


func next_wave() -> void:
	current_wave += 1
	current_wave_mobs.clear()
	current_wave_mobs = WaveController.get_wave(current_wave)
	if not NetworkHelper.is_multiplayer():
		_display_wave()
		_start_wave()
	elif NetworkHelper.is_multiplayer_is_host():
		SteamNetwork.rpc_all_clients(self, '_server_start_wave', [current_wave])


func _server_start_wave(server_id:int, current_wave:int) -> void:
	self.current_wave = current_wave
	_display_wave()
	if server_id == SteamNetwork._my_steam_id:
		_start_wave()


func _display_wave() -> void:
	emit_signal('wave_started', current_wave)


func _start_wave() -> void:
	if spawners.empty():
		print("No Valid Spawners Found")
		return
	print(current_wave_mobs)
	_spawn_next_enemy()

func _server_spawn_enemy(server_id:int, enemy_type:int, spawner:int) -> void:
	self.current_wave = current_wave
	_spawn_enemy(enemy_type, spawner)
	if server_id == SteamNetwork._my_steam_id:
		$SpawnTimer.start(1.0)


func _spawn_next_enemy() -> void:
	if current_wave_mobs.keys().empty(): return
	var enemy_type:int = current_wave_mobs.keys().front()
	if not NetworkHelper.is_multiplayer():
		_spawn_enemy(enemy_type, randi() % spawners.size())
	elif NetworkHelper.is_multiplayer_is_host():
		SteamNetwork.rpc_all_clients(self, '_server_spawn_enemy', [enemy_type, randi() % spawners.size()])
	
	current_wave_mobs[enemy_type] -= 1
	if current_wave_mobs[enemy_type] == 0:
		current_wave_mobs.erase(enemy_type)


func _spawn_enemy(enemy_type:int, spawner_id:int) -> void:
	var spawner = spawners[spawner_id]
	
	var enemy
	
	match enemy_type:
		WaveController.mobs.TRASH: 
			enemy = trash_mob_scene.instance()
			trash.add_child(enemy)
		WaveController.mobs.FAST: 
			enemy = fast_mob_scene.instance()
			fast.add_child(enemy)
		WaveController.mobs.RANGE: 
			enemy = ranged_mob_scene.instance()
			ranged.add_child(enemy)
		WaveController.mobs.TANK: 
			enemy = tank_mob_scene.instance()
			tank.add_child(enemy)
	
	enemy.global_transform = spawner.global_transform


func _on_Timer_timeout():
	if not NetworkHelper.is_multiplayer():
		next_wave()
	elif NetworkHelper.is_multiplayer_is_host():
		next_wave()


func _on_SpawnTimer_timeout():
	_spawn_next_enemy()
