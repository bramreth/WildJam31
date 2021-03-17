extends Spatial



export (int) var dmg_min = 1
export (int) var dmg_max = 1
export (int) var weapon_spread = 144
export (int) var max_ammo = 30
export (int) var knockback
export(Color) var dmg_col = Color.white

export (float) var crit_rate = 0.1
export (int) var crit_mul = 2

export (float) var rof = 1.0

#range
export (int) var explosion
# multiplier for splash damage
export (float) var splash_mul

export (Texture) var icon

export (int) var fire
export (int) var frost
export (int) var poison
export (int) var bleed
export (int) var electric
export (float) var electric_range = 10.0
export (int) var electric_jumps = 5

export (bool) var projectile
export (int) var ricochet
export (String) var flavour

enum rarities{
	COMMON,
	UNCOMMON,
	RARE,
	EPIC
}

export(rarities) var rarity

func _ready():
	assert(get_child(0), "must have child glb")
	
