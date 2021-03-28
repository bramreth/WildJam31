extends Spatial

func attach(node):
	$balloon/CurveTween.play(0.3, Vector3.ZERO, Vector3.ONE) 
	global_transform.origin = node.global_transform.origin
	global_transform.origin.y += 3
	$PinJoint.set("nodes/node_a", node.get_path())
	$PinJoint.global_transform.origin = (global_transform.origin - node.global_transform.origin) / 2


func _on_Timer_timeout():
	for b in get_tree().get_nodes_in_group("balloon"):
		if $balloon.global_transform.origin.distance_to(b.global_transform.origin) < 10:
			b.get_parent().queue_free()
	queue_free()


func _on_CurveTween_curve_tween(sat):
	$balloon/balloon/generatedClone.scale = sat
