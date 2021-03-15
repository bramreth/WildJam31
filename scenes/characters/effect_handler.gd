extends Node

var frost_counter = 0
var poison_counter = []
var bleed_counter = 0
var burn_counter = []

export (NodePath) var frost_particles_path
var frost = null

export (NodePath) var poison_particles_path
var poison = null

export (NodePath) var bleed_particles_path
var bleed = null

export (NodePath) var burn_particles_path
var burn = null

var max_stax = 16
var max_bleed = 5

func _ready():
	frost = get_node(frost_particles_path)
	poison = get_node(poison_particles_path)
	bleed = get_node(bleed_particles_path)
	burn = get_node(burn_particles_path)

func add_poison(poison_in):
	poison.emitting = true
	if len(poison_counter) < max_stax:
		poison_counter.append(poison_in)
	if $PoisonTimer.is_stopped():
		$PoisonTimer.start()


func _on_PoisonTimer_timeout():
	if poison_counter:
		var p = poison_counter.pop_back()
		get_parent().poison_dmg(p)
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
	
func add_bleed(bleed_in):
	bleed.emitting = true
	bleed_counter = clamp(bleed_counter + bleed_in, 0, max_bleed)
	if $BleedTimer.is_stopped():
		$BleedTimer.start()


func _on_BleedTimer_timeout():
	if bleed_counter:
		get_parent().bleed_dmg(bleed_counter)
		bleed_counter = clamp(bleed_counter -1, 0, max_bleed)
	if bleed_counter <= 0:
		bleed.emitting = false
	$BleedTimer.start()

func add_burn(burn_in):
	burn.emitting = true
	if len(burn_counter) < max_stax:
		burn_counter.append(burn_in)
	if $BurnTimer.is_stopped():
		$BurnTimer.start()

func _on_FireTimer_timeout():
	if burn_counter:
		var b = burn_counter.pop_back()
		get_parent().burn_dmg(b)
	if burn_counter.empty():
		burn.emitting = false
	$BurnTimer.start()
	
func die():
	burn.emitting = false
	bleed.emitting = false
	poison.emitting = false
	frost.emitting = false
	
