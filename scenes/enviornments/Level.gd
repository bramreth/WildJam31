extends Spatial
class_name Level

onready var navigation:Navigation = $Navigation
var current_wave = []
var wave = 0
var wave_active = false

export(Resource) var level_env
export(Resource) var reward_env

export (bool) var debug = false

var max_mob_count = 24
var spawners

var at_reward = false

signal wave_start(wave_out)
signal wave_end()

var spawners_map = {}

func _ready():
	Event.connect(Event.START_WAVE, self, "start_wave")
	Event.connect(Event.WARP, self, "goto_reward")
	Event.connect(Event.RESPAWN, self, "respawn")
	randomize()
	wave = Game.get_wave_selected()-1
	spawners = get_tree().get_nodes_in_group("spawner")
	for s in spawners:
		spawners_map[s] = false
		s.connect("all_dead", self, "spawner_done")
	Event.emit_signal(Event.OPEN_DOORS)
	Game.start_level()
	if debug: 
		Game.debug = true
		Event.emit_signal(Event.SETUP_DEBUG)
	else:
		$wave_controller/major_timer.start(0)
	$player.transform = $spawn_pad/Spatial.global_transform
	
func spawner_done(spawner):
	spawners_map[spawner] = true
	check_spawners()
	
func check_spawners():
	for s in spawners_map:
		if not spawners_map[s]:
			return
	end_wave()

func calculate_path(start_pos:Vector3, end_pos:Vector3) -> Array:
	var path:PoolVector3Array = navigation.get_simple_path(start_pos, end_pos)
	var path_array:Array = path
	path_array.pop_front()
	return path_array

func divvy_wave(wave):
	for cluster in wave:
		for enemy_type in cluster:
			var enemy_count = cluster[enemy_type]
	#		for i in range(enemy_count):
			spawners.shuffle()
			for s in spawners:
				spawners_map[s] = false
				var batch = (enemy_count/ len(spawners)) + 1
				if batch < enemy_count:
					s.add_enemies(enemy_type, batch)
				else:
					s.add_enemies(enemy_type, enemy_count)
				enemy_count -= batch
			# should be an enum and a number of enemies

func start_wave():
	if wave_active: return
	print("start_wave")
	wave_active = true
	current_wave = $wave_controller.get_wave(wave)
	divvy_wave(current_wave)
	start_spawning()
	spawn_ammo()
	emit_signal("wave_start", wave + 1)
	
func end_wave():
	print("end wave")
	wave_active = false
	wave += 1
	emit_signal("wave_end")
	if int(wave) % 3 == 0:
		print("reward")
		$player.warp(false)
	elif Game.continuous_waves:
		start_wave()
	
func check_spawning_done(map):
	for k in map:
		if map[k] == true: return false
	return true
	
func start_spawning():
	var remaining_map = {}
	while true:
		for spawner in spawners:
			yield(get_tree().create_timer(0.3), "timeout")
			if len(get_tree().get_nodes_in_group("enemy")) <= max_mob_count:
				remaining_map[spawner] = spawner.spawn_a_mob()
			if check_spawning_done(remaining_map): 
				print("done")
				return
			
func spawn_ammo():
	randomize()
	for aspawner in get_tree().get_nodes_in_group("ammo_spawner"):
		aspawner.spawn_pickup(randf())

func _on_major_timer_timeout():
	Event.emit_signal(Event.START_WAVE)
	
func respawn():
	at_reward = false
	$WorldEnvironment.environment = level_env
	$player.transform = $spawn_pad/Spatial.global_transform
	$Navigation.visible = true
	$reward_room.visible = false
	
func goto_reward():
	if not at_reward:
		at_reward = true
		$reward_room.goto_reward(at_reward)
		$WorldEnvironment.environment = reward_env
		var spawn = get_tree().get_nodes_in_group("spawn_point").front()
		$player.global_transform = $reward_room.get_reward_spawn()
		$Navigation.visible = false
		$reward_room.visible = true
	else:
		respawn()
