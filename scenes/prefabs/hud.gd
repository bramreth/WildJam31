extends Control

var cache_clip = 0
var cache_res = 0

onready var health_bar:TextureProgress = $HealthDisplay/HealthBar
onready var health_bar_label:Label = $HealthDisplay/HealthBar/health
onready var health_pqueue = $HealthDisplay/pqueue
onready var armor_bar:TextureProgress = $HealthDisplay/ArmorBar
onready var armor_bar_label:Label = $HealthDisplay/ArmorBar/armor
onready var armor_pqueue = $HealthDisplay/pqueuearmor

onready var ammo_label:Label = $ammocorner/ammo
onready var max_ammo_label:Label = $ammocorner/maxammo

func _ready():
	get_tree().get_nodes_in_group("level").front().connect("wave_start", self, "wave_start")
	get_tree().get_nodes_in_group("level").front().connect("wave_end", self, "wave_end")

func update_health(health, armor) -> void:
	health_bar.value = health
	health_bar_label.text = String(health)
	armor_bar.value = armor
	armor_bar_label.text = String(armor)
	if armor <= 0:
		armor_bar_label.visible = false
	else:
		armor_bar_label.visible = true
	
func update_ammo_counter():
	ammo_label.text = cache_clip
	max_ammo_label.text = cache_res
	
func preppreload(clip, res):
	cache_clip = clip
	cache_res = res
	
func heal():
	health_pqueue.trigger()
	
func armor():
	armor_pqueue.trigger()

func wave_start(arg):
	$wave_info/Panel/Particles2D.amount = 48
	$wave_info/Panel/title.text = "Enemies inbound\nWave: " + str(arg)
	$wave_info/AnimationPlayer.play("show")
	$wave_info/waveTimer.start(0)
	
func wave_end():
	return
	$wave_info/Panel/Particles2D.amount = 64
	$wave_info/Panel/title.text = "Wave complete!\nScavenge!"
	$wave_info/AnimationPlayer.play("show")
	$wave_info/waveTimer.start(0)

func _on_Timer_timeout():
	$new_ammo/AnimationPlayer.play_backwards("show")


func _on_waveTimer_timeout():
	$wave_info/AnimationPlayer.play_backwards("show")


func _on_gun_new_ammo(node):
	$new_ammo/Panel/VBoxContainer/HBoxContainer/ammo_ico.texture = node.icon
	$new_ammo/Panel/VBoxContainer/HBoxContainer/ammo_name.text = node.name
	var rarities = node.rarities
	match(node.rarity):
		rarities.COMMON:
			$new_ammo/Panel/VBoxContainer/HBoxContainer/ammo_name.set("custom_colors/font_color", Color.whitesmoke)
		rarities.UNCOMMON:
			$new_ammo/Panel/VBoxContainer/HBoxContainer/ammo_name.set("custom_colors/font_color", Color.deepskyblue)
		rarities.RARE:
			$new_ammo/Panel/VBoxContainer/HBoxContainer/ammo_name.set("custom_colors/font_color", Color.yellow)
		rarities.EPIC:
			$new_ammo/Panel/VBoxContainer/HBoxContainer/ammo_name.set("custom_colors/font_color", Color.fuchsia)
	$new_ammo/AnimationPlayer.play("show")

func tuck_ammo():
	$new_ammo/AnimationPlayer.play_backwards("show")

func warp():
	$WarpPlayer.play("warp")

func _on_gun_reload(clip, reserve):
	preppreload(str(clip), str(reserve))
	$ammocorner/clipflat/AnimationPlayer.play("reload")


func _on_gun_update_ammo(ammo_ref, clip, reserve, spread):
	$ammocorner/ammo_type.texture = ammo_ref.icon
	ammo_label.text = str(clip)
	max_ammo_label.text = str(reserve)

func _on_gun_change_ammo_type(ammo_ref, clip, reserve):
	ammo_label.text = str(clip)
	max_ammo_label.text = str(reserve)
	$ammocorner/ammo_type.texture = ammo_ref.icon
	$ammocorner/ammo_type/AnimationPlayer.play("set_ammo")
