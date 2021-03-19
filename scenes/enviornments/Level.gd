extends Spatial
class_name Level

onready var navigation:Navigation = $Navigation
var current_wave = []
var wave = 0
var wave_active = false

var max_mob_count = 24

var spawners

signal wave_start()
signal wave_end()

var spawners_map = {}

func _ready():
	spawners = get_tree().get_nodes_in_group("spawner")
	for s in spawners:
		spawners_map[s] = false
		s.connect("all_dead", self, "spawner_done")

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
	print(wave)
	for cluster in wave:
		for enemy_type in cluster:
			var enemy_count = cluster[enemy_type]
	#		for i in range(enemy_count):
			for s in spawners:
				spawners_map[s] = false
				var batch = (enemy_count/ len(spawners)) + 1
				print(batch)
				if batch < enemy_count:
					s.add_enemies(enemy_type, batch)
				else:
					s.add_enemies(enemy_type, enemy_count)
				enemy_count -= batch
			# should be an enum and a number of enemies

func _input(event):
	if not wave_active and Input.is_action_just_pressed("ui_page_up"):
		start_wave()

func start_wave():
	print("start_wave")
	wave_active = true
	current_wave = $wave_controller.get_wave(wave)
	divvy_wave(current_wave)
	start_spawning()
	emit_signal("wave_start")
	
func end_wave():
	print("end wave")
	wave_active = false
	wave += 1
	emit_signal("wave_end")

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
			
