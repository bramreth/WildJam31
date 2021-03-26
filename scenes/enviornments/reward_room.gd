extends Spatial

func _ready():
	goto_reward(false)

func get_reward_spawn():
	return $spawn_pad/Spatial.global_transform

func goto_reward(goto):
	visible = goto
	if goto:
		$MeshInstance/AnimationPlayer.seek(0, true)
		$MeshInstance/AnimationPlayer.play("title")
