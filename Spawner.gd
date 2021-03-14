extends Spatial

# a device for spawning waves of enemies
export (PackedScene) var enemy_1
export (PackedScene) var enemy_2
export (PackedScene) var enemy_3

export (int) var wave_size

func _ready():
	randomize()
	
func _process(delta):
	if get_child_count() < wave_size:
		var choice = randf()
		if choice < 0.33:
			add_child(enemy_1.instance())
		elif choice < 0.66:
			add_child(enemy_2.instance())
		else:
			add_child(enemy_3.instance())
			
