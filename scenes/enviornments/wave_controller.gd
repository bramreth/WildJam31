extends Node

enum mobs {
	TRASH,
	FAST, 
	RANGE,
	TANK
}

func _ready():
	randomize()
	for x in range(20):
		print(get_wave(x))

func trash_wave(level: int):
	return {mobs.TRASH: common(level)}
		
func fast_wave(level: int):
	return {mobs.FAST: uncommon(level)}
		
func range_wave(level: int):
	return {mobs.RANGE: uncommon(level)}
		
func tank_wave(level: int):
	return {mobs.TANK: common(level)}

func get_wave(iter: int):
	
	var wave = []
#	print(tier)
	if iter < 3:
		wave.append(trash_wave(iter))
	elif iter < 6:
		wave.append(trash_wave(iter))
		wave.append(fast_wave(max(iter-2, 0)))
	elif iter < 9:
		wave.append(trash_wave(iter))
		wave.append(range_wave(max(iter-5, 0)))
	elif iter == 9:
		wave.append(trash_wave(iter))
		wave.append(fast_wave(max(iter-5, 0)))
		wave.append(range_wave(max(iter-5, 0)))
	elif iter < 12:
		wave.append(trash_wave(iter))
		wave.append(tank_wave(max(iter-7, 0)))
	else:
		wave.append(trash_wave(iter))
		wave.append(fast_wave(max(iter-8, 0)))
		wave.append(range_wave(max(iter-8, 0)))
		wave.append(tank_wave(max(iter-8, 0)))
	print(wave)
	return wave

func common(iter: int):
	if iter <= 0: return 5
	elif iter == 1: return 8
	return iter + common(iter-1)
	
func uncommon(iter: int):
	if iter <= 0: return 0
	elif iter == 1: return 1
	return iter + uncommon(iter-1)

func boss(iter: int):
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
