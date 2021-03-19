extends Spatial

# a device for spawning waves of enemies
export (PackedScene) var enemy_trash
export (PackedScene) var enemy_fast
export (PackedScene) var enemy_range
export (PackedScene) var enemy_tank

var spawning = false

signal all_dead(this)

enum mobs {
	TRASH,
	FAST, 
	RANGE,
	TANK
}

var host_map = {}

var mob_map = {}

var wave_remaining = {
	mobs.TRASH: 0,
	mobs.FAST: 0,
	mobs.RANGE: 0,
	mobs.TANK: 0,
}

export (int) var wave_size

func _ready():
	randomize()
	host_map = {
		mobs.TRASH: get_node("trash"),
		mobs.FAST: get_node("fast"),
		mobs.RANGE: get_node("range"),
		mobs.TANK: get_node("tank"),
	}
	
	mob_map = {
		mobs.TRASH: enemy_trash,
		mobs.FAST: enemy_fast,
		mobs.RANGE: enemy_range,
		mobs.TANK: enemy_tank,
	}

func check_children(type):
	return host_map[type].get_child_count()

func monitor():
	if check_empty():
		emit_signal("all_dead", self)
	else:
		$Timer.start(0)
	

func check_empty():
	for type in mobs.values():
		if check_children(type) > 0:
			return false
	return true
		
func add_enemies(mob, num):
	spawning = true
	wave_remaining[mob] = num
#	$Timer.start(0)


func spawn_a_mob():
	for type in wave_remaining:
		if wave_remaining[type] > 0:
			host_map[type].add_child(mob_map[type].instance())
			wave_remaining[type] = max(wave_remaining[type]-1, 0)
			return true
	# spawning done monitor for dead kids
	monitor()
	return false

func _on_Timer_timeout():
	monitor()
