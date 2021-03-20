extends Spatial

var health_scene = preload("res://scenes/pickups/health.tscn")
var armor_scene = preload("res://scenes/pickups/armor.tscn")

var max_drops = 20
var health_list = []
var armor_list = []


func add_health(loc: Vector3):
	var new_pack = null
	if len(health_list) >= max_drops:
		health_list.pop_front().queue_free()
	new_pack = health_scene.instance()
	new_pack.global_transform.origin = loc
	new_pack.spawn_anim()
	add_child(new_pack)
	health_list.append(new_pack)
	

func add_armor(loc: Vector3):
	var new_pack = null
	if len(armor_list) >= max_drops:
		armor_list.pop_front().queue_free()
	new_pack = armor_scene.instance()
	new_pack.global_transform.origin = loc
	new_pack.spawn_anim()
	add_child(new_pack)
	armor_list.append(new_pack)
