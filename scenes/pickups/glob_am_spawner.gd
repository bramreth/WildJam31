extends Spatial

var common_1 = preload("res://scenes/pickups/drops/fries_drop.tscn")
var common_2 = preload("res://scenes/pickups/drops/eyeball_drop.tscn")
var common_3 = preload("res://scenes/pickups/drops/token_drop.tscn")
var common_4 = preload("res://scenes/pickups/drops/beer_drop.tscn")
var common_5 = preload("res://scenes/pickups/drops/cigarette_drop.tscn")

var max_drops = 20
var ammo_list = []

func _ready():
	randomize()
	

func add_ammo(loc: Vector3):
	var new_pack = null
	if len(ammo_list) >= max_drops:
		ammo_list.pop_front().queue_free()
	var choice = randf()
	if choice < 0.2:
		new_pack = common_1.instance()
	elif choice < 0.4:
		new_pack = common_2.instance()
	elif choice < 0.6:
		new_pack = common_3.instance()
	elif choice < 0.8:
		new_pack = common_4.instance()
	else:
		new_pack = common_5.instance()
	new_pack.global_transform.origin = loc
	add_child(new_pack)
	ammo_list.append(new_pack)
