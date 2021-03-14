extends Spatial

export (int) var damage
export (Curve) var weapon_spread
export (int) var max_ammo

func _ready():
	assert(get_child(0), "must have child glb")
