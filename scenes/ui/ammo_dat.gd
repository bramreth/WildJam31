extends ColorRect

var current = null



# TODO: set name to rarity colour

func setup(ammo_data):
	
	match(ammo_data.rarity):
		ammo_data.rarities.COMMON:
			$VBoxContainer/HBoxContainer/title.set("custom_colors/font_color", Color.whitesmoke)
			$VBoxContainer/title2.text = "common"
			$VBoxContainer/title2.set("custom_colors/font_color", Color.whitesmoke)
		ammo_data.rarities.UNCOMMON:
			$VBoxContainer/HBoxContainer/title.set("custom_colors/font_color", Color.deepskyblue)
			$VBoxContainer/title2.text = "uncommon"
			$VBoxContainer/title2.set("custom_colors/font_color", Color.deepskyblue)
		ammo_data.rarities.RARE:
			$VBoxContainer/HBoxContainer/title.set("custom_colors/font_color", Color.yellow)
			$VBoxContainer/title2.text = "rare"
			$VBoxContainer/title2.set("custom_colors/font_color", Color.yellow)
		ammo_data.rarities.EPIC:
			$VBoxContainer/HBoxContainer/title.set("custom_colors/font_color", Color.fuchsia)
			$VBoxContainer/title2.text = "epic"
			$VBoxContainer/title2.set("custom_colors/font_color", Color.fuchsia)
	current = ammo_data
	$VBoxContainer/HBoxContainer/title.text = current.name.replace("_", " ")
	$VBoxContainer/dmg.text = "damage: " + str(current.dmg_min) + " - " + str(current.dmg_max)
	$VBoxContainer/dmg.text = "damage: " + str(current.dmg_min) + " - " + str(current.dmg_max)
	if current.rof < 0.75:
		$VBoxContainer/rof.text = "fire rate: low"
	elif current.rof < 1.25:
		$VBoxContainer/rof.text = "fire rate: medium"
	elif current.rof < 2:
		$VBoxContainer/rof.text = "fire rate: high"
	else:
		$VBoxContainer/rof.text = "fire rate: absurd"
	
	if current.crit_rate < 0.1:
		$VBoxContainer/crit.text = "crit chance: low"
	elif current.crit_rate < 0.3:
		$VBoxContainer/crit.text = "crit chance: medium"
	elif current.crit_rate < 0.5:
		$VBoxContainer/crit.text = "crit chance: high"
	else:
		$VBoxContainer/crit.text = "crit chance: absurd"
	$VBoxContainer/critd.text = "crit damage: " + str(current.crit_mul) + "x"
	$VBoxContainer/frost.visible = current.frost
	$VBoxContainer/fire.visible = current.fire
	$VBoxContainer/poison.visible = current.poison
	$VBoxContainer/bleed.visible = current.bleed
	$VBoxContainer/electric.visible = current.electric
	if current.flavour:
		$VBoxContainer/flavour.visible = true
		$VBoxContainer/flavour.text =  current.flavour
	else:
		$VBoxContainer/flavour.visible = false
		
	
	
