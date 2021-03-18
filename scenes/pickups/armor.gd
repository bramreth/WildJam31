extends "res://scenes/pickups/drops/collectible.gd"

export (int) var heal = 25

func collectible_effect():
	player.add_armor(heal)
	hud.armor()

func can_collect():
	return player.armor < player.max_armor

