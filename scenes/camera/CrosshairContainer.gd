extends CenterContainer

onready var l = $anchor/cross/l
onready var u = $anchor/cross/u
onready var r = $anchor/cross/r
onready var d = $anchor/cross/d


func apply_spread(spread:float) -> void:
	l.position.x = -spread
	u.position.y = -spread
	r.position.x = spread
	d.position.y = spread


func hit_confirmed() -> void:
	$anchor/crosshair/AnimationPlayer.play("hit")
