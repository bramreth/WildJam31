extends Spatial

export (int) var dmg_min = 1
export (int) var dmg_max = 1
export (int) var weapon_spread = 144
export (int) var max_ammo
export (int) var knockback
export(Color) var dmg_col = Color.white

export (float) var crit_rate = 0.1
export (int) var crit_mul = 2

#range
export (int) var explosion
# multiplier for splash damage
export (float) var splash_mul

export (Texture) var icon

export (int) var fire
export (int) var frost
export (int) var poison

export (bool) var projectile
export (int) var ricochet

func _ready():
	assert(get_child(0), "must have child glb")
	
