extends KinematicBody

const GRAVITY:float = -9.8
const SNAP_VECTOR:Vector3 = Vector3.DOWN*3

export(int) var max_health = 20
onready var health:int = max_health
var dead:bool = false

export(float) var jump_force = 16.0
export(float) var speed = 10.0
export(float) var sprint_speed_modifier = 1.5
export(float) var acceleration = 9.5

var velocity:Vector3 = Vector3.ZERO
var current_speed:float = speed
var input_direction:Vector3 = Vector3.ZERO
var current_snap:Vector3 = SNAP_VECTOR

var _hang_time:float = 0.0

func _ready():
	pass

func _physics_process(_delta: float) -> void:
	var hvel:Vector3 = velocity
	var move_direction:Vector3 = calculate_move_direction()
	hvel = hvel.linear_interpolate(move_direction * current_speed, acceleration * _delta)
	velocity.x = hvel.x
	
	apply_gravity(_delta)
	
	velocity.z = hvel.z
	velocity = move_and_slide_with_snap(velocity, current_snap, Vector3.UP, true)
	if current_snap != SNAP_VECTOR and is_on_floor():
		current_snap = SNAP_VECTOR
		
	if is_running():
		current_speed = speed * sprint_speed_modifier
	else: 
		current_speed = speed
	
# region stubs
func calculate_move_direction() -> Vector3:
	return Vector3.ZERO
	
func is_running() -> bool:
	return false
#end region
	
func apply_gravity(delta:float) -> void:
	if is_on_floor():
		_hang_time = delta
		velocity.y += _hang_time * GRAVITY
	else:
		_hang_time += delta / 3
		velocity.y += _hang_time * GRAVITY

func damage(amount:int) -> void:
	if dead: return
	health = max(health - amount, 0)
	if health <= 0 and not dead:
		_on_death()

func _on_death() -> void:
	dead = true
	queue_free()