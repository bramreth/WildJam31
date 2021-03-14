extends Spatial

export (int) var damage
export (Curve) var weapon_spread
export (int) var max_ammo
export (int) var knockback

export (Texture) var icon

export (int) var fire
export (int) var frost
export (int) var poison
export (int) var explosion
export (bool) var projectile
export (int) var ricochet

func _ready():
	assert(get_child(0), "must have child glb")
