extends "res://scenes/characters/character.gd"

onready var camera:Camera = $camera/juicy_cam

func _ready():
	$camera.update_health(health, armor)
	
func add_dmg_anim(col, num, pos):
	$camera.set_enemy_dmg(col, num, pos)

func _physics_process(_delta: float) -> void:
	input_direction = get_input_direction()
	if is_on_floor() and Input.is_action_just_pressed("move_jump"):
		_jump()

#region overrides
func calculate_move_direction() -> Vector3:
	var cam_xform:Transform = camera.get_global_transform()
	var move_direction:Vector3 = Vector3.ZERO
	move_direction += cam_xform.basis.z.normalized() * input_direction.z
	move_direction += cam_xform.basis.x.normalized() * input_direction.x
	move_direction.y = 0
	return move_direction.normalized()

func is_running() -> bool:
	return Input.is_action_pressed("move_sprint")
#region end

static func get_input_direction() -> Vector3:
	return Vector3(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"), 0, Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward"))

func _jump() -> void:
	velocity.y = jump_force
	current_snap = Vector3.ZERO


func damage(amount:int, knockback:Vector3 = Vector3.ZERO) -> void:
	.damage(amount, knockback)
	$camera.update_health(health, armor)
	

func _on_death() -> void:
	get_tree().reload_current_scene()
