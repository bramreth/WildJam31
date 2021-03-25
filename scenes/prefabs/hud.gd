extends Control

var cache_clip = 0
var cache_res = 0

func _ready():
	get_tree().get_nodes_in_group("level").front().connect("wave_start", self, "wave_start")
	get_tree().get_nodes_in_group("level").front().connect("wave_end", self, "wave_end")

func update_health(health, armor) -> void:
	$HealthDisplay/HealthBar.value = health
	$HealthDisplay/HealthBar/health.text = String(health)
	$HealthDisplay/ArmorBar.value = armor
	$HealthDisplay/ArmorBar/armor.text = String(armor)
	if armor <= 0:
		$HealthDisplay/ArmorBar/armor.visible = false
	else:
		$HealthDisplay/ArmorBar/armor.visible = true
	
func update_ammo_counter():
	$ammo.text = cache_clip
	$maxammo.text = cache_res
	
func preppreload(clip, res):
	cache_clip = clip
	cache_res = res
	
func heal():
	$HealthDisplay/pqueue.trigger()
	
func armor():
	$HealthDisplay/pqueuearmor.trigger()

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
	$new_ammo/Panel/VBoxContainer/HBoxContainer/ammo_ico.texture = node.get_ammo().icon
	$new_ammo/Panel/VBoxContainer/HBoxContainer/ammo_name.text = node.get_ammo().name
	var rarities = node.get_ammo().rarities
	match(node.get_ammo().rarity):
		rarities.COMMON:
			$new_ammo/Panel/VBoxContainer/HBoxContainer/ammo_name.set("custom_colors/font_color", Color.whitesmoke)
		rarities.UNCOMMON:
			$new_ammo/Panel/VBoxContainer/HBoxContainer/ammo_name.set("custom_colors/font_color", Color.deepskyblue)
		rarities.RARE:
			$new_ammo/Panel/VBoxContainer/HBoxContainer/ammo_name.set("custom_colors/font_color", Color.yellow)
		rarities.EPIC:
			$new_ammo/Panel/VBoxContainer/HBoxContainer/ammo_name.set("custom_colors/font_color", Color.fuchsia)
	$new_ammo/AnimationPlayer.play("show")
	$new_ammo/Timer.start()
