extends Spatial

export (String) var ammo_name = ""
var player_ammo = null
var hud = null
var picking_up = false

# Called when the node enters the scene tree for the first time.
func _ready():
	player_ammo = get_tree().get_nodes_in_group("player_ammo").front()
	hud = get_tree().get_nodes_in_group("hud").front()
	var dat = $pickup_container.get_child(0)
	print("bmarker", dat.rarity)
	match(dat.rarity):
		dat.rarities.COMMON:
			$Particles.draw_pass_1.material.albedo_color = Color.whitesmoke
		dat.rarities.UNCOMMON:
			$Particles.draw_pass_1.material.albedo_color = Color.deepskyblue
		dat.rarities.RARE:
			$Particles.draw_pass_1.material.albedo_color = Color.yellow
		dat.rarities.EPIC:
			$Particles.draw_pass_1.material.albedo_color = Color.fuchsia
	print($Particles.draw_pass_1.material.albedo_color)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if picking_up:
		
		global_transform.origin = global_transform.origin.linear_interpolate(player_ammo.global_transform.origin, delta * 16)
		global_transform.origin = global_transform.origin.linear_interpolate(player_ammo.global_transform.origin, delta * 16)


func _on_Area_body_entered(body):
	$Particles.emitting = false
	print(body.name)
	var dat = $pickup_container.get_child(0)
	var ammo_amount = int(rand_range(dat.max_ammo * 3, dat.max_ammo * 6))
	player_ammo.add_ammo(ammo_name, ammo_amount)
	hud.add_ammo($pickup_container.get_child(0))
	picking_up = true
	$pickup_container/bouncer.stop()
	$AnimationPlayer.play("pickup")


func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
