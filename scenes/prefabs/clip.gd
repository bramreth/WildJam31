extends Spatial

var ammo_types = {}
var ammo_index  = 0
var ammo = null

var new_ammo = 0

var starting_ammo = ["pencil", "balloon"]
var ammo_amounts = {}

var ammo_slots = {}
onready var active_slot = get_node("held_ammo/ammo_slot1")

signal init()
signal added_ammo(slot)

func equip_ammo(name_in: String):
	var chosen = $ammo_container.get_node(name_in).duplicate()
	if chosen == null:
		print("invalid ammo name: " + name_in)
		return
	var free_slot = $held_ammo.next_free_slot(active_slot)
	if free_slot:
		print("empty slot found, picking up: " + name_in)
		active_slot.visible = false
		free_slot.replace_ammo(chosen)
		active_slot = free_slot
		emit_signal("added_ammo", free_slot)
		return
	print("no empty slots, replacing " + active_slot.name)
	active_slot.replace_ammo(chosen)
	emit_signal("added_ammo", active_slot)
	
#
func add_ammo(name_in: String, amount:int = -1):
	$held_ammo.add_ammo(name_in, amount)
	owner.emit_signal('update_ammo', active_slot.get_ammo(), active_slot.get_clip(), active_slot.get_reserve(), 0)

func swap_ammo(forward=true):
	active_slot.visible = false
	var next_slot = active_slot.next_slot() if forward else active_slot.last_slot()
	while not next_slot.slot_taken():
		next_slot = next_slot.next_slot() if forward else next_slot.last_slot()
	active_slot = next_slot
	active_slot.visible = true
	make_visible()
	
func swap_ammo_slot(slot: Node):
	active_slot.visible = false
	active_slot = slot
	make_visible()
	
func swap_ammo_num(slot: int):
	active_slot.visible = false
	active_slot = $held_ammo.get_node("ammo_slot"+str(slot))
	if not active_slot.slot_taken():
		swap_ammo()
	else:
		make_visible()
	
func make_visible():
	active_slot.visible = true
	$ammo_data/Viewport/ammo_data.setup(active_slot.get_ammo())
	$AnimationPlayer.play("show")
	owner.emit_signal('update_ammo', active_slot.get_ammo(), active_slot.get_clip(), active_slot.get_reserve(), 0)


func _ready():
	Event.connect(Event.EQUIP_AMMO, self, "equip_ammo")
	for n in starting_ammo:
		equip_ammo(n)
	print("ammo equiped")
#	for amm in $ammo_container.get_children():
#		if amm.name in starting_ammo:
#			ammo_types[amm] = {
#				'clip': amm.max_ammo,
#				'reserve': amm.max_ammo
#				}
##	ammo_types = $ammo_container.get_children()
#	ammo = ammo_types.keys()[ammo_index]
#	ammo.visible = true
#	$ammo_data/Viewport/ammo_data.setup(ammo)
#
func show_ammo(show: bool):
	active_slot.visible = true
	if show:
		$AnimationPlayer.play("show")
	else:
		$AnimationPlayer.play_backwards("show")

func tuck_ammo():
	active_slot.visible = false
	$AnimationPlayer.seek(0, true)

func show_dat(on):
	if on:
		$ammo_data/AnimationPlayer.play("show_dat")
	else:
		$ammo_data/AnimationPlayer.play_backwards("show_dat")

func get_ammo_data():
	return active_slot

func can_fire():
	if active_slot.clip > 0:
		active_slot.clip -= 1 
		return true
	return false

func reload_current():
	var max_ammo = active_slot.get_ammo().max_ammo
	if active_slot.reserve > 0:
		var amount_to_reload = max_ammo - active_slot.clip
		if active_slot.reserve > amount_to_reload:
			active_slot.reserve -= amount_to_reload
			active_slot.clip = max_ammo
		else:
			active_slot.clip += active_slot.reserve
			active_slot.reserve = 0
