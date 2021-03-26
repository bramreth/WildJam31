extends Spatial

func goto_reward(goto):
	visible = goto
	if goto:
		$MeshInstance/AnimationPlayer.seek(0, true)
		$MeshInstance/AnimationPlayer.play("title")
