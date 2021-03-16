extends Spatial

export (String) var ammo_name = ""
var player_ammo = null

# Called when the node enters the scene tree for the first time.
func _ready():
	player_ammo = get_tree().get_nodes_in_group("player_ammo").front()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_body_entered(body):
	print(body.name)
	$AnimationPlayer.play("pickup")


func _on_AnimationPlayer_animation_finished(anim_name):
	player_ammo.add_ammo(ammo_name)
	queue_free()
