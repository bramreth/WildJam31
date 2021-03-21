extends Area


export(float) var explosion_radius = 10.0
export(int) var explosion_damage = 40
export(float) var explosion_force = 50.0


func explode():
	$Tween.interpolate_property($CollisionShape.shape, 'radius', 0.1, explosion_radius, 0.2, Tween.TRANS_EXPO, Tween.EASE_IN)
	$Tween.start()
	yield($Tween,"tween_all_completed")
	queue_free()


func _on_Explosion_body_entered(body):
	if body.is_in_group('enemy') or body.is_in_group('player'):
		if _explosion_line_of_sight(body):
			var direction = global_transform.origin.direction_to(body.global_transform.origin).normalized()
			if body.is_in_group('player'): body.damage(explosion_damage, direction * explosion_force)
			else: body.explosion_dmg(explosion_damage, direction * explosion_force)


func _explosion_line_of_sight(body):
	$RayCast.enabled = true
	$RayCast.cast_to = body.global_transform.origin - global_transform.origin
	$RayCast.force_raycast_update()
	if $RayCast.is_colliding():
		if $RayCast.get_collider() == body:
			$RayCast.enabled = false
			return true
	$RayCast.enabled = false
	return false
	
