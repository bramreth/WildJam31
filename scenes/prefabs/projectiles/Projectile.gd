extends KinematicBody


export(int) var damage = 10
export(float) var projectile_speed = 1.0

var direction:Vector3


func fire_at(direction:Vector3):
	self.direction = direction


func _physics_process(delta):
	var collision := move_and_collide(direction * 1.0)
	if collision != null:
		var collider = collision.get_collider()
		if collider.is_in_group('player'):
			collider.damage(damage)
		$CollisionShape.disabled = true
		$AnimationPlayer.play("hit")
		direction = Vector3.ZERO
		set_physics_process(false)
