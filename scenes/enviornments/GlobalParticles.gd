extends Node

func _ready() -> void:
	ParticleEventBus.connect("particles_requested", self, "_trigger_particles")


func _trigger_particles(particle_types:Array, global_location:Vector3, data:Dictionary) -> void:
	for particle_type in particle_types:
		match(particle_type):
			ParticleEventBus.HIT: _trigger_simple_particle($hit_particles, global_location, data)
			ParticleEventBus.CLOUD: _trigger_simple_particle($cloud_particles, global_location, data)
			ParticleEventBus.DAMAGE: _trigger_damage_particle($damage_particles, global_location, data)
			ParticleEventBus.SPRITE: _trigger_sprite_particle($sprite_particles, global_location, data)
			_: pass


func _trigger_simple_particle(p_queue, global_location:Vector3, data:Dictionary) -> void:
	var p:Particles = p_queue.get_next_particle()
	p.global_transform.origin = global_location
	p.look_at(data['norm'], Vector3(0,1,0))
	p_queue.trigger()


func _trigger_damage_particle(sprite_p_queue, global_location:Vector3, data:Dictionary) -> void:
	var p:Particles = sprite_p_queue.get_next_particle()
	p.global_transform.origin = global_location
	if data['crit']:
		p.set_number_col_crit(data['dmg'], data['color'])
	else:
		p.set_number_col(data['dmg'], data['color'])
	p.look_at(data['norm'], Vector3(0,1,0))
	sprite_p_queue.trigger()


func _trigger_sprite_particle(sprite_p_queue, global_location:Vector3, data:Dictionary) -> void:
	var p:Particles = sprite_p_queue.get_next_particle()
	p.global_transform.origin = global_location
	p.draw_pass_1.material.albedo_texture = data['icon']
	p.look_at(data['norm'], Vector3(0,1,0))
	sprite_p_queue.trigger()
