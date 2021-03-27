extends Spatial

export(bool) var is_projectile = false
export(PackedScene) var projectile

export(bool) var is_shotgun = false
export(int) var pellets = 5

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

#export (bool) var projectile
export (int) var ricochet
export (String) var flavour

enum rarities{
	COMMON,
	UNCOMMON,
	RARE,
	EPIC
}

export(NodePath) var outline_path
var outline = null
export(bool) var held_camera = false

export(rarities) var rarity

func _ready():
	assert(get_child(0), "must have child glb")
	outline = get_node(outline_path)
	outline.visible = false
	if held_camera:
		get_child(0).get_child(0).set_layer_mask_bit(0, false)
		get_child(0).get_child(0).set_layer_mask_bit(1, true)
		get_child(0).get_child(0).cast_shadow = false
	
