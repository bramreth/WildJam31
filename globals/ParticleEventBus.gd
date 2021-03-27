extends Node

const HIT:String = 'hit'
const CLOUD:String = 'cloud'
const SPRITE:String = 'sprite'
const DAMAGE:String = 'damage'

signal particles_requested(types, global_location, data)


func request_particles(types:Array, global_location:Vector3, particle_data:Dictionary) -> void:
	emit_signal("particles_requested", types, global_location, particle_data)
