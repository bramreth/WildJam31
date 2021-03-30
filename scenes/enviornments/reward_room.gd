extends Spatial

var drop1 = preload("res://scenes/pickups/drops/strawb_milk_drop.tscn")

export (NodePath) var player_path
var player = null

func _ready():
	player = get_node(player_path)
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
	


func _on_chest_item_taken():
	$chest.wipe()
	$chest2.wipe()
	$chest3.wipe()
	$Timer.start(0)


func _on_Timer_timeout():
	$player.warp(true)
