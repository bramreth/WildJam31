extends Control

func _ready():
	$new_ammo/AnimationPlayer.seek(0, true)
	$new_ammo/AnimationPlayer.play("show")
	$new_ammo/AnimationPlayer.stop()
	
	$wave_info/AnimationPlayer.seek(0, true)
	$wave_info/AnimationPlayer.play("show")
	$wave_info/AnimationPlayer.stop()
	get_tree().get_nodes_in_group("level").front().connect("wave_start", self, "wave_start")
	get_tree().get_nodes_in_group("level").front().connect("wave_end", self, "wave_end")

func _input(event):
	if Input.is_action_just_pressed("ui_page_up"):
		print("reset")
		$new_ammo/AnimationPlayer.seek(0, true)
		$new_ammo/AnimationPlayer.play("show")
		$new_ammo/AnimationPlayer.stop()
		
		$wave_info/AnimationPlayer.seek(0, true)
		$wave_info/AnimationPlayer.play("show")
		$wave_info/AnimationPlayer.stop()

func update_health(health, armor) -> void:
	$HealthDisplay/HealthBar.value = health
	$HealthDisplay/HealthBar/health.text = String(health)
	$HealthDisplay/ArmorBar.value = armor
	$HealthDisplay/ArmorBar/armor.text = String(armor)
	if armor <= 0:
		$HealthDisplay/ArmorBar/armor.visible = false
	else:
		$HealthDisplay/ArmorBar/armor.visible = true

func add_ammo(ammo_dat):
	$new_ammo/Panel/VBoxContainer/HBoxContainer/ammo_ico.texture = ammo_dat.icon
	$new_ammo/Panel/VBoxContainer/HBoxContainer/ammo_name.text = ammo_dat.name
	match(ammo_dat.rarity):
		ammo_dat.rarities.COMMON:
			$new_ammo/Panel/VBoxContainer/HBoxContainer/ammo_name.set("custom_colors/font_color", Color.whitesmoke)
		ammo_dat.rarities.UNCOMMON:
			$new_ammo/Panel/VBoxContainer/HBoxContainer/ammo_name.set("custom_colors/font_color", Color.deepskyblue)
		ammo_dat.rarities.RARE:
			$new_ammo/Panel/VBoxContainer/HBoxContainer/ammo_name.set("custom_colors/font_color", Color.yellow)
		ammo_dat.rarities.EPIC:
			$new_ammo/Panel/VBoxContainer/HBoxContainer/ammo_name.set("custom_colors/font_color", Color.fuchsia)
	$new_ammo/AnimationPlayer.play("show")
	$new_ammo/Timer.start()
	
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
