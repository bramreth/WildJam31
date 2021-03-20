extends Spatial

onready var last_shot = get_node("shot2")


var index = 0

export (OpenSimplexNoise) var n
var time = 0


func _ready():
	randomize()

func _process(delta):
	time += delta*10

func fire():
	var shot = randf()
	var shot_queue = [$shot1, $shot3, $shot4]
	print(shot_queue[index], n.get_noise_1d(time))
	shot_queue[index].pitch_scale = 1.0 + (n.get_noise_1d(time)/10)
	shot_queue[index].playing = true
	index = (index + 1) % 3
	
#	var shot_map = {
#		$shot2: [$shot3, $shot4],
#		$shot3: [$shot2, $shot4],
#		$shot4: [$shot3, $shot2]
#	}
#	var shot = randf()
#	var o1 = shot_map[last_shot][0]
#	var o2 = shot_map[last_shot][1]
#	if shot < 0.5:
#		o1.playing = true
#		last_shot = o1
#	else:
#		o2.playing = true
#		last_shot = o2
	
