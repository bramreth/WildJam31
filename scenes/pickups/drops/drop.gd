extends Spatial

export (String) var ammo_name = ""
var player_ammo = null
var picking_up = false

# Called when the node enters the scene tree for the first time.
func _ready():
	player_ammo = get_tree().get_nodes_in_group("player_ammo").front()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if picking_up:
		
		global_transform.origin = global_transform.origin.linear_interpolate(player_ammo.global_transform.origin, delta * 16)
		global_transform.origin = global_transform.origin.linear_interpolate(player_ammo.global_transform.origin, delta * 16)


func _on_Area_body_entered(body):
	print(body.name)
	player_ammo.add_ammo(ammo_name)
	picking_up = true
	$AnimationPlayer.play("pickup")


func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
