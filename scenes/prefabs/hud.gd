extends Control

func _ready():
	$new_ammo/AnimationPlayer.play_backwards("show")
	$new_ammo/AnimationPlayer.seek(0, true)

func update_health(health, armor) -> void:
	$HealthDisplay/HealthBar.value = health
	$HealthDisplay/HealthBar/health.text = String(health)
	$HealthDisplay/ArmorBar.value = armor
	$HealthDisplay/ArmorBar/armor.text = String(armor)
	if armor <= 0:
		$HealthDisplay/ArmorBar/armor.visible = false

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

func _on_Timer_timeout():
	$new_ammo/AnimationPlayer.play_backwards("show")
