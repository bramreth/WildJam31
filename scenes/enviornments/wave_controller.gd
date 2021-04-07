extends Node
class_name WaveController

enum mobs {
	TRASH,
	FAST, 
	RANGE,
	TANK
}

static func trash_wave(level: int):
	return common(level)
		
static  func fast_wave(level: int):
	return uncommon(level)
	
static func range_wave(level: int):
	return uncommon(level)
		
static func tank_wave(level: int):
	return common(level)

static func get_wave(iter: int):
	
	var wave = {}
	if iter < 3:
		wave[mobs.TRASH] = trash_wave(iter)
	elif iter < 6:
		wave[mobs.TRASH] = trash_wave(iter)
		wave[mobs.FAST] = fast_wave(max(iter-2, 0))
	elif iter < 9:
		wave[mobs.TRASH] = trash_wave(iter)
		wave[mobs.FAST] = fast_wave(max(iter-5, 0))
	elif iter == 9:
		wave[mobs.TRASH] = trash_wave(iter)
		wave[mobs.FAST] = fast_wave(max(iter-5, 0))
		wave[mobs.RANGE] = range_wave(max(iter-5, 0))
	elif iter < 12:
		wave[mobs.TRASH] = trash_wave(iter)
		wave[mobs.TANK] = tank_wave(max(iter-7, 0))
	else:
		wave[mobs.TRASH] = trash_wave(iter)
		wave[mobs.FAST] = fast_wave(max(iter-8, 0))
		wave[mobs.RANGE] = range_wave(max(iter-8, 0))
		wave[mobs.TANK] = tank_wave(max(iter-8, 0))
	return wave

static func common(iter: int):
	if iter <= 0: return 5
	elif iter == 1: return 8
	return iter + common(iter-1)
	
static func uncommon(iter: int):
	if iter <= 0: return 0
	elif iter == 1: return 1
	return iter + uncommon(iter-1)

static func boss(iter: int):
	return iter

"""
ratio
e1 1 < 3

e2 1 < 6

e3 1 < 9

e1 0.66 e2 0.33 < 
e1 0.66 e3 0.33
e2 0.66 e1 0.33
e2 0.66 e3 0.33
e3 0.66 e1 0.33
e3 0.66 e2 0.33

e1 0,33 e2 0.33 e3 0.33
"""
