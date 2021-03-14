extends Node

var frost_counter = 0
var poison_counter = []

export (NodePath) var frost_particles_path
var frost = null

export (NodePath) var poison_particles_path
var poison = null

var max_stax = 16

func _ready():
	frost = get_node(frost_particles_path)
	poison = get_node(poison_particles_path)

func add_poison(poison_in):
	poison.emitting = true
	if len(poison_counter) < max_stax:
		poison_counter.append(poison_in)
	if $PoisonTimer.is_stopped():
		$PoisonTimer.start()


func _on_PoisonTimer_timeout():
	if poison_counter:
		var p = poison_counter.back()
		get_parent().poison_dmg(p)
		poison_counter[len(poison_counter)-1] -= 1
		if p <= 1:
			poison_counter.pop_back()
	if poison_counter.empty():
		poison.emitting = false
	$PoisonTimer.start()
	
func add_frost(frost_in):
	frost_counter = clamp(frost_counter + frost_in, 0, 6)
	frost.emitting = true
	get_parent().frost_speed_mod = 1.0 - (0.1 * frost_counter)
	if $FrostTimer.is_stopped():
		$FrostTimer.start()

func _on_FrostTimer_timeout():
	if frost_counter > 0:
		frost_counter -= 1
		get_parent().frost_dmg(1)
		if frost_counter == 0: 
			get_parent().frost_speed_mod = 1.0 - (0.1 * frost_counter)
			frost.emitting = false
	$FrostTimer.start()
