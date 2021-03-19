extends RigidBody

export(float) var initial_velocity = 150.0
export(PackedScene) var explosion
var damage = 10


func fire_at(direction:Vector3):
	apply_central_impulse(direction * initial_velocity)
	$Timer.start()


func _on_Timer_timeout():
	queue_free()



func _on_Area_body_entered(body):
	disable()


func _on_Area_area_entered(area):
#	print(area.owner.name)
#	if area.is_in_group('enemy'):
#		area.owner.damage(500)
	disable()


func disable():
	sleeping = true
	$CollisionShape.disabled = true
#	$Are.set_deffered('monitoring', false)
	var ex = explosion.instance()
	get_tree().get_nodes_in_group('level').front().add_child(ex)
	ex.global_transform.origin = global_transform.origin
	ex.explode()
	$AnimationPlayer.play("hit")
