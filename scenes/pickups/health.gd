extends "res://scenes/pickups/drops/collectible.gd"

export (int) var heal = 25

func collectible_effect():
	player.add_health(heal)
	hud.heal()

func can_collect():
	return player.health < player.max_health
