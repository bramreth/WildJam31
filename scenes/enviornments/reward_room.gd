extends Spatial

var drop1 = preload("res://scenes/pickups/drops/strawb_milk_drop.tscn")

func _ready():
	goto_reward(false)

func get_reward_spawn():
	return $spawn_pad/Spatial.global_transform

func goto_reward(goto):
	visible = goto
	if goto:
		for chest in get_tree().get_nodes_in_group("reward_chest"):
			chest.add_reward(drop1.instance())
			chest.reset_lid()
		$MeshInstance/AnimationPlayer.seek(0, true)
		$MeshInstance/AnimationPlayer.play("title")
	
