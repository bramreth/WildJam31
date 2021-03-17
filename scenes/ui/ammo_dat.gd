extends ColorRect

var current = null

# TODO: set name to rarity colour

func setup(ammo_data):
	current = ammo_data
	$VBoxContainer/HBoxContainer/title.text = current.name
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
	if current.flavour:
		$VBoxContainer/flavour.visible = true
		$VBoxContainer/flavour.text =  current.flavour
	else:
		$VBoxContainer/flavour.visible = false
		
	
	
